package com.app.service;

import java.util.List;

import com.app.dto.PlaceDTO;
import com.app.dto.PlaceReviewDTO;

public interface PlaceService {

	public int updateAreaBasedListPlaces() throws Exception;

	public int updateAreaBasedListPlaces(int maxPages, int pageSize, int batchSize) throws Exception;

	public PlaceDTO getPlaceByPlaceNo(Long placeNo) throws Exception;

	public List<String> getPlaceTagNamesByPlaceNo(Long placeNo) throws Exception;

	public List<String> getPlacePhotoUrlsByPlaceNo(Long placeNo) throws Exception;

	public List<PlaceReviewDTO> getPlaceReviewsByPlaceNo(Long placeNo) throws Exception;
}
