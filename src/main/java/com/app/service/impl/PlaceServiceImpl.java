package com.app.service.impl;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.app.dao.AreaBasedList2Repository;
import com.app.dao.PlaceDAO;
import com.app.dto.PlaceDTO;
import com.app.dto.PlaceHoursDTO;
import com.app.dto.PlaceReviewDTO;
import com.app.dto.PlaceTagMapDTO;
import com.app.dto.TourResponseDTO;
import com.app.service.ImportProgressTracker;
import com.app.service.PlaceHoursParser;
import com.app.service.PlaceService;
import com.app.service.PlaceTagClassifier;

@Service
public class PlaceServiceImpl implements PlaceService {

	private static final int DEFAULT_MAX_PAGES = 1;
	private static final int DEFAULT_PAGE_SIZE = 300;
	private static final int DEFAULT_BATCH_SIZE = 300;
	private static final int DEFAULT_HOURS_BATCH_SIZE = 500;
	private static final int DEFAULT_HOURS_PARALLELISM = 6;
	private static final int MAX_HOURS_PARALLELISM = 12;

	@Autowired
	private AreaBasedList2Repository apiRepository;

	@Autowired
	private PlaceDAO placeDAO;

	@Autowired
	private PlaceTagClassifier placeTagClassifier;

	@Autowired
	private PlaceHoursParser placeHoursParser;

	@Autowired
	private ImportProgressTracker importProgressTracker;

	@Override
	public int updateAreaBasedListPlaces() throws Exception {
		return updateAreaBasedListPlaces(DEFAULT_MAX_PAGES, DEFAULT_PAGE_SIZE, DEFAULT_BATCH_SIZE);
	}

	@Override
	public int updateAreaBasedListPlaces(int maxPages, int pageSize, int batchSize) throws Exception {
		int safeMaxPages = Math.max(1, maxPages);
		int safePageSize = Math.max(1, pageSize);
		int safeBatchSize = Math.max(1, batchSize);
		importProgressTracker.startPlaceImport(safePageSize, safeMaxPages);

		try {
			// Full refresh: clear PLACE/PLACE_TAG_MAP and reset sequences.
			placeDAO.resetPlaceImportData();

			int result = 0;
			List<PlaceDTO> buffer = new ArrayList<>(safeBatchSize);
			List<PlaceTagMapDTO> tagMapBuffer = new ArrayList<>(safeBatchSize * 10);

			for (int pageNo = 1; pageNo <= safeMaxPages; pageNo++) {
				List<TourResponseDTO.PlaceDto> items = apiRepository.requestApi_areaBasedList2(pageNo, safePageSize);
				if (items == null || items.isEmpty()) {
					break;
				}
				importProgressTracker.onPlacePageFetched(pageNo, items.size());

				for (TourResponseDTO.PlaceDto item : items) {
					Long placeNo = placeDAO.getNextPlaceNo();
					List<String> tagCodes = placeTagClassifier.classifyTagCodes(item);
					buffer.add(toPlaceDTO(item, placeNo, tagCodes));
					tagMapBuffer.addAll(toPlaceTagMapDTOList(placeNo, tagCodes));

					if (buffer.size() >= safeBatchSize) {
						int inserted = placeDAO.updateAreaBasedListPlacesBatch(buffer);
						result += inserted;
						importProgressTracker.addInserted(inserted);
						placeDAO.insertPlaceTagMapBatch(tagMapBuffer);
						buffer.clear();
						tagMapBuffer.clear();
					}
				}

				if (items.size() < safePageSize) {
					break;
				}
			}

			if (!buffer.isEmpty()) {
				int inserted = placeDAO.updateAreaBasedListPlacesBatch(buffer);
				result += inserted;
				importProgressTracker.addInserted(inserted);
				placeDAO.insertPlaceTagMapBatch(tagMapBuffer);
			}

			importProgressTracker.complete("Place import completed (" + result + " rows)");
			return result;
		} catch (Exception e) {
			importProgressTracker.fail(e);
			throw e;
		}
	}

	@Override
	public int updatePlaceHours() throws Exception {
		return updatePlaceHours(DEFAULT_HOURS_BATCH_SIZE, DEFAULT_HOURS_PARALLELISM);
	}

	@Override
	public int updatePlaceHours(int batchSize) throws Exception {
		return updatePlaceHours(batchSize, DEFAULT_HOURS_PARALLELISM);
	}

	@Override
	public int updatePlaceHours(int batchSize, int parallelism) throws Exception {
		int safeBatchSize = Math.max(1, batchSize);
		int safeParallelism = Math.max(1, Math.min(parallelism, MAX_HOURS_PARALLELISM));
		ExecutorService executor = Executors.newFixedThreadPool(safeParallelism);

		try {
			placeDAO.resetPlaceHoursImportData();

			List<PlaceDTO> places = placeDAO.selectPlacesForHoursImport();
			importProgressTracker.startHoursImport(places == null ? 0 : places.size(), safeBatchSize);
			if (places == null || places.isEmpty()) {
				importProgressTracker.complete("No places found for hours import.");
				return 0;
			}

			int insertedRows = 0;
			List<PlaceHoursDTO> hoursBuffer = new ArrayList<>(safeBatchSize);
			ExecutorCompletionService<List<PlaceHoursDTO>> completionService = new ExecutorCompletionService<>(executor);

			int submitted = 0;
			int completed = 0;
			for (PlaceDTO place : places) {
				completionService.submit(() -> loadAndParseHours(place));
				submitted++;

				if (submitted - completed >= safeParallelism) {
					List<PlaceHoursDTO> parsed = takeCompletedHours(completionService);
					completed++;
					importProgressTracker.onHoursPlaceProcessed(completed);
					insertedRows += appendHoursAndFlush(parsed, hoursBuffer, safeBatchSize);
				}
			}

			while (completed < submitted) {
				List<PlaceHoursDTO> parsed = takeCompletedHours(completionService);
				completed++;
				importProgressTracker.onHoursPlaceProcessed(completed);
				insertedRows += appendHoursAndFlush(parsed, hoursBuffer, safeBatchSize);
			}

			if (!hoursBuffer.isEmpty()) {
				int inserted = placeDAO.insertPlaceHoursBatch(hoursBuffer);
				insertedRows += inserted;
				importProgressTracker.addInserted(inserted);
			}
			importProgressTracker.complete("Hours import completed (" + insertedRows + " rows)");
			return insertedRows;
		} catch (Exception e) {
			importProgressTracker.fail(e);
			throw e;
		} finally {
			executor.shutdownNow();
		}
	}

	private List<PlaceHoursDTO> loadAndParseHours(PlaceDTO place) {
		String operatingHoursRawText = fetchOperatingHoursRawText(place.getPlaceContentId(), place.getPlaceCategory());
		List<PlaceHoursDTO> parsed = placeHoursParser.parse(place.getPlaceNo(), operatingHoursRawText);
		return parsed == null ? Collections.emptyList() : parsed;
	}

	private List<PlaceHoursDTO> takeCompletedHours(ExecutorCompletionService<List<PlaceHoursDTO>> completionService) throws Exception {
		try {
			return completionService.take().get();
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			throw e;
		} catch (ExecutionException e) {
			Throwable cause = e.getCause();
			if (cause instanceof Exception) {
				throw (Exception) cause;
			}
			throw new RuntimeException(cause);
		}
	}

	private int appendHoursAndFlush(List<PlaceHoursDTO> parsed, List<PlaceHoursDTO> hoursBuffer, int batchSize) throws Exception {
		if (parsed == null || parsed.isEmpty()) {
			return 0;
		}

		hoursBuffer.addAll(parsed);
		if (hoursBuffer.size() < batchSize) {
			return 0;
		}

		int inserted = placeDAO.insertPlaceHoursBatch(hoursBuffer);
		importProgressTracker.addInserted(inserted);
		hoursBuffer.clear();
		return inserted;
	}

	@Override
	public PlaceDTO getPlaceByPlaceNo(Long placeNo) throws Exception {
		return placeDAO.selectPlaceByPlaceNo(placeNo);
	}

	@Override
	public List<String> getPlaceTagNamesByPlaceNo(Long placeNo) throws Exception {
		return placeDAO.selectPlaceTagNamesByPlaceNo(placeNo);
	}

	@Override
	public List<String> getPlacePhotoUrlsByPlaceNo(Long placeNo) throws Exception {
		List<String> photoUrlList = placeDAO.selectPlacePhotoUrlsByPlaceNo(placeNo);
		if (photoUrlList == null || photoUrlList.isEmpty()) {
			return new ArrayList<>();
		}
		Set<String> uniquePhotoUrlSet = new LinkedHashSet<>();
		for (String photoUrl : photoUrlList) {
			if (photoUrl != null && !photoUrl.isBlank()) {
				uniquePhotoUrlSet.add(photoUrl.trim());
			}
		}
		return new ArrayList<>(uniquePhotoUrlSet);
	}

	@Override
	public List<PlaceReviewDTO> getPlaceReviewsByPlaceNo(Long placeNo) throws Exception {
		return placeDAO.selectPlaceReviewsByPlaceNo(placeNo);
	}

	@Override
	public List<PlaceHoursDTO> getPlaceHoursByPlaceNo(Long placeNo) throws Exception {
		return placeDAO.selectPlaceHoursByPlaceNo(placeNo);
	}

	private PlaceDTO toPlaceDTO(TourResponseDTO.PlaceDto item, Long placeNo, List<String> tagCodes) {
		PlaceDTO placeDTO = new PlaceDTO();
		placeDTO.setPlaceNo(placeNo);
		placeDTO.setPlaceContentId(truncate(item.getContentid(), 30));
		placeDTO.setPlaceName(truncate(item.getTitle(), 200));
		placeDTO.setPlaceCategory(truncate(item.getContenttypeid(), 50));
		placeDTO.setPlaceAddress(truncate(item.getAddr1(), 500));
		placeDTO.setPlaceLatitude(parseDoubleOrNull(item.getMapy()));
		placeDTO.setPlaceLongitude(parseDoubleOrNull(item.getMapx()));
		placeDTO.setPlaceNumber(preserveOriginalPlaceNumber(item.getTel()));
		placeDTO.setPlaceThumbnailUrl(truncate(item.getFirstimage2(), 1000));
		return placeDTO;
	}

	private List<PlaceTagMapDTO> toPlaceTagMapDTOList(Long placeNo, List<String> tagCodes) {
		List<PlaceTagMapDTO> list = new ArrayList<>();
		for (String tagCode : tagCodes) {
			PlaceTagMapDTO placeTagMapDTO = new PlaceTagMapDTO();
			placeTagMapDTO.setPlaceNo(placeNo);
			placeTagMapDTO.setTagCode(tagCode);
			placeTagMapDTO.setTagWeight(1.0);
			placeTagMapDTO.setTagSource("RULE");
			placeTagMapDTO.setTagConfidence(1.0);
			list.add(placeTagMapDTO);
		}
		return list;
	}

	private String fetchOperatingHoursRawText(TourResponseDTO.PlaceDto item) {
		try {
			return apiRepository.requestApi_detailIntro2OperatingHours(item.getContentid(), item.getContenttypeid());
		} catch (Exception e) {
			return "";
		}
	}

	private String fetchOperatingHoursRawText(String contentId, String contentTypeId) {
		try {
			return apiRepository.requestApi_detailIntro2OperatingHours(contentId, contentTypeId);
		} catch (Exception e) {
			return "";
		}
	}

	private Double parseDoubleOrNull(String value) {
		if (value == null || value.isBlank()) {
			return null;
		}
		try {
			return Double.parseDouble(value);
		} catch (NumberFormatException e) {
			return null;
		}
	}

	private String preserveOriginalPlaceNumber(String rawValue) {
		if (rawValue == null) {
			return null;
		}
		String value = rawValue.trim();
		if (value.isEmpty()) {
			return null;
		}
		return truncate(value, 255);
	}

	private String truncate(String value, int maxLength) {
		if (value == null) {
			return null;
		}
		String trimmed = value.trim();
		if (trimmed.length() <= maxLength) {
			return trimmed;
		}
		return trimmed.substring(0, maxLength);
	}
}
