<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<meta charset="UTF-8">
	<meta name="_csrf" content="${_csrf.token}" />
	<meta name="_csrf_header" content="${_csrf.headerName}" />
	<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/mainPage.css">
	<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
	<title>#Trip</title>
</head>
<body>
	<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

	<section class="analysis-section">
		<div class="analysis-container">
			<div class="analysis-content">
				<span class="badge">Travel Type Test</span>
				<h1>나의 여행 성향을 확인해보세요</h1>
				<p>
					10개 카테고리 테스트로 여행 취향을 찾고,<br>
					비슷한 여행자들의 추천 루트를 발견해보세요.
				</p>
				<div class="analysis-action">
					<c:choose>
						<c:when test="${not empty usersDTO and not empty usersDTO.userNo}">
							<a href="${pageContext.request.contextPath}/hashTrip/analysis" class="btn-analysis">여행유형 테스트 시작하기</a>
						</c:when>
						<c:otherwise>
							<a href="javascript:void(0);" onclick="checkLogin()" class="btn-analysis">여행유형 테스트 시작하기</a>
						</c:otherwise>
					</c:choose>
					<p id="changing-text" class="sub-text">* 취향은 정답이 아니라 방향입니다.</p>
				</div>
			</div>

			<div class="analysis-image">
				<div class="floating-card type-1">#제주도</div>
				<div class="floating-card type-2">#맛집</div>
				<div class="floating-card type-3">#액티비티</div>
				<div class="floating-card type-1">#감성숙소</div>
				<div class="floating-card type-2">#인생샷</div>
				<div class="floating-card type-3">#차박</div>
				<div class="floating-card type-1 solo">#혼자여행</div>
			</div>
		</div>
	</section>

	<section class="recommend-section">
		<div class="recommend-container">
			<div class="section-title">
				<h2>지금 인기 있는 #Trip 추천 여행지</h2>
			</div>

			<div class="search-bar-wrapper">
				<div class="search-input-box">
					<i class="search-icon">🔍</i>
					<input type="text" id="destinationSearch" placeholder="어디로 떠나고 싶으신가요?">
				</div>
			</div>

			<div class="main-pref-filter-panel" id="main-pref-filter-panel">
				<div class="main-pref-filter-head">
					<div class="main-pref-filter-title">취향 탐색 필터</div>
					<div class="main-pref-actions">
						<button type="button" class="main-pref-action-btn main-pref-apply" id="mainPrefApplyBtn">필터 적용</button>
						<button type="button" class="main-pref-action-btn main-pref-reset" id="mainPrefResetBtn">초기화</button>
					</div>
				</div>

				<div class="main-pref-top" id="mainPrefTop">
					<c:forEach var="pref" items="${preferenceCategories}">
						<button type="button"
							class="main-pref-chip main-pref-top-chip"
							data-pref-category="${pref.categoryKey}">
							${pref.icon} ${pref.label}
						</button>
					</c:forEach>
				</div>

				<div class="main-pref-sub-wrap">
					<div class="main-pref-sub" id="mainPrefSub">
						<span class="main-pref-empty">상위 카테고리를 먼저 선택해 주세요</span>
					</div>
				</div>

				<div class="main-pref-summary hidden" id="mainPrefSummary"></div>
			</div>

			<div class="recommend-wrapper">
				<button class="slider-btn prev-btn" id="prevBtn" type="button">&#10094;</button>
				<button class="slider-btn next-btn" id="nextBtn" type="button">&#10095;</button>

				<div class="recommend-cards" id="sliderTrack">
					<c:forEach var="place" items="${places}">
						<div class="travel-card" data-place-no="${place.placeNo}">
							<div class="card-image" data-thumb-url="<c:out value='${place.placeThumbnailUrl}' />">
								<button type="button"
									class="like-btn${place.savedYn eq 'Y' ? ' active' : ''}"
									data-place-id="${place.placeNo}">
									<span class="heart-icon">
										<c:choose>
											<c:when test="${place.savedYn eq 'Y'}">♥</c:when>
											<c:otherwise>♡</c:otherwise>
										</c:choose>
									</span>
								</button>
							</div>
							<div class="card-info">
								<h3><c:out value="${place.placeName}" /></h3>
								<p><c:out value="${place.placeAddress}" /></p>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</div>
	</section>

	<div class="main-wishlist-modal" id="mainWishlistModal" aria-hidden="true">
		<div class="main-wishlist-modal-dim" data-main-wishlist-close="true"></div>
		<div class="main-wishlist-modal-panel" role="dialog" aria-modal="true" aria-labelledby="mainWishlistModalTitle">
			<div class="main-wishlist-modal-head">
				<h3 id="mainWishlistModalTitle">찜 저장</h3>
				<button type="button" class="main-wishlist-close" data-main-wishlist-close="true">닫기</button>
			</div>
			<p class="main-wishlist-help">카테고리를 선택하면 해당 장소가 찜 목록에 저장됩니다.</p>

			<div class="main-wishlist-row">
				<label for="mainWishlistCategorySelect">카테고리</label>
				<select id="mainWishlistCategorySelect" class="main-wishlist-select"></select>
				<button type="button" id="mainWishlistSaveBtn" class="main-wishlist-primary">저장</button>
			</div>

			<div class="main-wishlist-row">
				<label for="mainWishlistNewCategory">카테고리 추가</label>
				<div class="main-wishlist-create-wrap">
					<input type="text" id="mainWishlistNewCategory" class="main-wishlist-input" maxlength="100" placeholder="예: 가족 여행" />
					<button type="button" id="mainWishlistCreateBtn" class="main-wishlist-secondary">추가</button>
				</div>
			</div>

			<p class="main-wishlist-message hidden" id="mainWishlistMessage"></p>
		</div>
	</div>

	<jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />

	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<script type="text/javascript">
		document.addEventListener('DOMContentLoaded', function() {
			const contextPath = '${pageContext.request.contextPath}';
			const track = document.getElementById('sliderTrack');
			const searchInput = document.getElementById('destinationSearch');
			const prevBtn = document.getElementById('prevBtn');
			const nextBtn = document.getElementById('nextBtn');
			const textElement = document.getElementById('changing-text');

			const mainPrefTop = document.getElementById('mainPrefTop');
			const mainPrefSub = document.getElementById('mainPrefSub');
			const mainPrefSummary = document.getElementById('mainPrefSummary');
			const mainPrefApplyBtn = document.getElementById('mainPrefApplyBtn');
			const mainPrefResetBtn = document.getElementById('mainPrefResetBtn');
			const wishlistModal = document.getElementById('mainWishlistModal');
			const wishlistCategorySelect = document.getElementById('mainWishlistCategorySelect');
			const wishlistSaveBtn = document.getElementById('mainWishlistSaveBtn');
			const wishlistCreateBtn = document.getElementById('mainWishlistCreateBtn');
			const wishlistNewCategoryInput = document.getElementById('mainWishlistNewCategory');
			const wishlistMessage = document.getElementById('mainWishlistMessage');

			const csrfTokenEl = document.querySelector('meta[name="_csrf"]');
			const csrfHeaderEl = document.querySelector('meta[name="_csrf_header"]');

			const token = csrfTokenEl ? csrfTokenEl.getAttribute('content') : '';
			const header = csrfHeaderEl ? csrfHeaderEl.getAttribute('content') : '';

			const placeholderImageUrl = contextPath + '/resources/images/place-placeholder.svg';

			const preferenceCategoryLabelMap = {};
			<c:forEach var="pref" items="${preferenceCategories}">
			preferenceCategoryLabelMap['${pref.categoryKey}'] = '${pref.label}';
			</c:forEach>

			const selectedPreferenceCategories = new Set();
			const selectedPreferenceTags = new Map();
			let appliedPreferenceCategory = '';
			let appliedPreferenceTagCodes = [];
			let appliedPreferenceTagCode = '';
			let appliedPreferenceTagNames = [];
			let pendingWishlistButton = null;

			let slideIndex = 0;
			const moveDistance = 390;

			function escapeHtml(value) {
				return String(value == null ? '' : value)
					.replace(/&/g, '&amp;')
					.replace(/</g, '&lt;')
					.replace(/>/g, '&gt;')
					.replace(/"/g, '&quot;')
					.replace(/'/g, '&#39;');
			}

			function resolveThumbnailUrl(rawUrl) {
				if (!rawUrl) {
					return placeholderImageUrl;
				}
				const trimmed = String(rawUrl).trim().replace(/\\/g, '/');
				if (!trimmed) {
					return placeholderImageUrl;
				}
				if (/^(https?:)?\/\//i.test(trimmed) || trimmed.startsWith('data:') || trimmed.startsWith('blob:')) {
					return trimmed;
				}
				if (trimmed.startsWith('/')) {
					if (contextPath && trimmed.startsWith(contextPath + '/')) {
						return trimmed;
					}
					return contextPath + trimmed;
				}
				return contextPath + '/' + trimmed.replace(/^\.?\//, '');
			}

			function applyCardImages(rootElement) {
				const root = rootElement && rootElement.querySelectorAll ? rootElement : document;
				root.querySelectorAll('.card-image[data-thumb-url]').forEach(function(cardImage) {
					const mainImageUrl = resolveThumbnailUrl(cardImage.dataset.thumbUrl);
					cardImage.style.backgroundImage = "url('" + mainImageUrl + "'), url('" + placeholderImageUrl + "')";
					cardImage.style.backgroundSize = 'cover, cover';
					cardImage.style.backgroundPosition = 'center, center';
				});
			}

			function updateSlider() {
				if (!track) {
					return;
				}

				const visibleCards = track.querySelectorAll('.travel-card');
				const maxIndex = Math.max(0, visibleCards.length - 3);
				if (slideIndex > maxIndex) {
					slideIndex = maxIndex;
				}
				if (slideIndex < 0) {
					slideIndex = 0;
				}

				track.style.transform = 'translateX(-' + (slideIndex * moveDistance) + 'px)';

				if (prevBtn) {
					prevBtn.style.opacity = (slideIndex === 0) ? '0.3' : '1';
				}
				if (nextBtn) {
					nextBtn.style.opacity = (slideIndex >= maxIndex || visibleCards.length <= 3) ? '0.3' : '1';
				}
			}

			function createPlaceCardHtml(place) {
				const placeNo = place.placeNo || place.PLACE_NO || 0;
				const placeName = escapeHtml(place.placeName || '이름 없음');
				const placeAddress = escapeHtml(place.placeAddress || '주소 없음');
				const thumb = escapeHtml(place.placeThumbnailUrl || '');
				const isLiked = (place.savedYn === 'Y');
				const activeClass = isLiked ? ' active' : '';
				const heartIcon = isLiked ? '♥' : '♡';

				return ''
					+ '<div class="travel-card" data-place-no="' + placeNo + '">'
					+ '  <div class="card-image" data-thumb-url="' + thumb + '">'
					+ '    <button type="button" class="like-btn' + activeClass + '" data-place-id="' + placeNo + '">'
					+ '      <span class="heart-icon">' + heartIcon + '</span>'
					+ '    </button>'
					+ '  </div>'
					+ '  <div class="card-info">'
					+ '    <h3>' + placeName + '</h3>'
					+ '    <p>' + placeAddress + '</p>'
					+ '  </div>'
					+ '</div>';
			}

			function renderSearchResults(data) {
				if (!track) {
					return;
				}

				if (!Array.isArray(data) || data.length === 0) {
					track.innerHTML = ''
						+ '<div class="travel-card is-empty">'
						+ '  <div class="card-info">'
						+ '    <h3>검색 결과가 없습니다.</h3>'
						+ '    <p>검색어 또는 필터를 바꿔서 다시 시도해 주세요.</p>'
						+ '  </div>'
						+ '</div>';
					slideIndex = 0;
					updateSlider();
					return;
				}

				track.innerHTML = data.map(createPlaceCardHtml).join('');
				applyCardImages(track);
				slideIndex = 0;
				updateSlider();
			}

			function performSearch() {
				const keyword = searchInput ? searchInput.value.trim() : '';
				const requestData = {
					keyword: keyword,
					prefCategory: appliedPreferenceCategory,
					prefTagCode: appliedPreferenceTagCode
				};

				$.ajax({
					url: contextPath + '/hashTrip/searchApi',
					type: 'GET',
					data: requestData,
					dataType: 'json',
					success: function(data) {
						renderSearchResults(data);
					},
					error: function(xhr) {
						alert('검색 중 오류가 발생했습니다. (' + xhr.status + ')');
					}
				});
			}

			function setLikeButtonState(btn, active) {
				if (!btn) {
					return;
				}
				btn.classList.toggle('active', Boolean(active));
				const icon = btn.querySelector('.heart-icon');
				if (icon) {
					icon.textContent = active ? '♥' : '♡';
				}
			}

			function syncSelectedTagsWithCategories() {
				Array.from(selectedPreferenceTags.entries()).forEach(function(entry) {
					const tagCode = entry[0];
					const tagInfo = entry[1];
					if (!tagInfo || !selectedPreferenceCategories.has(tagInfo.categoryKey)) {
						selectedPreferenceTags.delete(tagCode);
					}
				});
			}

			function clearSelectedPreferenceTags() {
				selectedPreferenceTags.clear();
			}

			function setWishlistMessage(message, isError) {
				if (!wishlistMessage) {
					return;
				}
				if (!message) {
					wishlistMessage.textContent = '';
					wishlistMessage.classList.add('hidden');
					wishlistMessage.classList.remove('error');
					return;
				}
				wishlistMessage.textContent = message;
				wishlistMessage.classList.remove('hidden');
				wishlistMessage.classList.toggle('error', Boolean(isError));
			}

			function getRequestHeaders(jsonContentType) {
				const headers = {};
				if (jsonContentType) {
					headers['Content-Type'] = 'application/json';
				}
				if (header && token) {
					headers[header] = token;
				}
				return headers;
			}

			function renderWishlistCategories(categories, preferredCategoryType) {
				if (!wishlistCategorySelect) {
					return;
				}

				const source = Array.isArray(categories) ? categories : [];
				const usable = source.filter(function(category) {
					if (!category || !category.categoryNo) {
						return false;
					}
					return String(category.categoryIsUsed || 'Y').toUpperCase() !== 'N';
				});

				wishlistCategorySelect.innerHTML = '';
				if (usable.length === 0) {
					const option = document.createElement('option');
					option.value = '';
					option.textContent = '카테고리를 먼저 만들어 주세요.';
					wishlistCategorySelect.appendChild(option);
					wishlistCategorySelect.disabled = true;
					if (wishlistSaveBtn) {
						wishlistSaveBtn.disabled = true;
					}
					return;
				}

				usable.forEach(function(category) {
					const option = document.createElement('option');
					option.value = String(category.categoryNo);
					option.textContent = String(category.categoryType || '카테고리');
					if (preferredCategoryType && option.textContent === preferredCategoryType) {
						option.selected = true;
					}
					wishlistCategorySelect.appendChild(option);
				});

				wishlistCategorySelect.disabled = false;
				if (wishlistSaveBtn) {
					wishlistSaveBtn.disabled = false;
				}
			}

			function closeWishlistModal() {
				if (!wishlistModal) {
					return;
				}
				wishlistModal.classList.remove('is-open');
				wishlistModal.setAttribute('aria-hidden', 'true');
				document.body.classList.remove('modal-open');
				setWishlistMessage('');
				pendingWishlistButton = null;
			}

			function loadWishlistCategories(preferredCategoryType) {
				return fetch(contextPath + '/customer/wishlist/categories', {
					method: 'GET',
					headers: getRequestHeaders(false)
				})
					.then(function(response) {
						return response.ok ? response.json() : null;
					})
					.then(function(data) {
						if (!data) {
							setWishlistMessage('카테고리를 불러오지 못했습니다.', true);
							return;
						}
						if (data.result === 'LOGIN_REQUIRED') {
							alert('로그인이 필요한 서비스입니다.');
							location.href = contextPath + '/auth/login';
							return;
						}
						if (data.result !== 'SUCCESS') {
							setWishlistMessage('카테고리를 불러오지 못했습니다.', true);
							return;
						}
						renderWishlistCategories(data.categories, preferredCategoryType);
						if (Array.isArray(data.categories) && data.categories.length === 0) {
							setWishlistMessage('카테고리를 먼저 생성한 뒤 저장해 주세요.', true);
						} else {
							setWishlistMessage('');
						}
					})
					.catch(function() {
						setWishlistMessage('카테고리를 불러오지 못했습니다.', true);
					});
			}

			function openWishlistModal(button) {
				if (!wishlistModal || !button) {
					return;
				}
				pendingWishlistButton = button;
				setWishlistMessage('');
				if (wishlistNewCategoryInput) {
					wishlistNewCategoryInput.value = '';
				}
				wishlistModal.classList.add('is-open');
				wishlistModal.setAttribute('aria-hidden', 'false');
				document.body.classList.add('modal-open');
				loadWishlistCategories();
			}

			function createWishlistCategory() {
				const categoryType = wishlistNewCategoryInput ? wishlistNewCategoryInput.value.trim() : '';
				if (!categoryType) {
					setWishlistMessage('카테고리 이름을 입력해 주세요.', true);
					if (wishlistNewCategoryInput) {
						wishlistNewCategoryInput.focus();
					}
					return;
				}

				fetch(contextPath + '/customer/wishlist/categories', {
					method: 'POST',
					headers: getRequestHeaders(true),
					body: JSON.stringify({
						categoryType: categoryType
					})
				})
					.then(function(response) {
						return response.ok ? response.json() : null;
					})
					.then(function(data) {
						if (!data) {
							setWishlistMessage('카테고리 생성에 실패했습니다.', true);
							return;
						}
						if (data.result === 'LOGIN_REQUIRED') {
							alert('로그인이 필요한 서비스입니다.');
							location.href = contextPath + '/auth/login';
							return;
						}
						if (data.result !== 'SUCCESS') {
							setWishlistMessage('카테고리 생성에 실패했습니다.', true);
							return;
						}
						renderWishlistCategories(data.categories, categoryType);
						if (wishlistNewCategoryInput) {
							wishlistNewCategoryInput.value = '';
						}
						setWishlistMessage('카테고리가 생성되었습니다.', false);
					})
					.catch(function() {
						setWishlistMessage('카테고리 생성에 실패했습니다.', true);
					});
			}

			function saveWishlistWithCategory() {
				if (!pendingWishlistButton) {
					return;
				}
				const categoryNo = wishlistCategorySelect ? wishlistCategorySelect.value : '';
				if (!categoryNo) {
					setWishlistMessage('카테고리를 선택해 주세요.', true);
					return;
				}

				const placeNo = pendingWishlistButton.getAttribute('data-place-id');
				const sendData = {
					placeNo: placeNo,
					status: 'Y',
					categoryNo: categoryNo
				};

				$.ajax({
					type: 'POST',
					url: contextPath + '/customer/savePlace',
					contentType: 'application/json',
					data: JSON.stringify(sendData),
					beforeSend: function(xhr) {
						if (header && token) {
							xhr.setRequestHeader(header, token);
						}
					},
					success: function(res) {
						if (res && res.body === 'SUCCESS') {
							setLikeButtonState(pendingWishlistButton, true);
							closeWishlistModal();
							return;
						}
						if (res && res.body === 'LOGIN_REQUIRED') {
							alert('로그인이 필요한 서비스입니다.');
							location.href = contextPath + '/auth/login';
							return;
						}
						if (res && res.body === 'NEED_CATEGORY') {
							setWishlistMessage('유효한 카테고리를 선택해 주세요.', true);
							loadWishlistCategories();
							return;
						}
						if (res && res.body === 'ALREADY_SAVED') {
							setLikeButtonState(pendingWishlistButton, true);
							closeWishlistModal();
							return;
						}
						setWishlistMessage('찜 저장에 실패했습니다.', true);
					},
					error: function(xhr) {
						if (xhr && xhr.status === 403) {
							setWishlistMessage('보안 토큰이 만료되었습니다. 새로고침 후 다시 시도해 주세요.', true);
							return;
						}
						setWishlistMessage('찜 저장에 실패했습니다.', true);
					}
				});
			}

			function cancelWishlist(btn) {
				if (!btn) {
					return;
				}

				const placeNo = btn.getAttribute('data-place-id');
				const sendData = {
					placeNo: placeNo,
					status: 'N'
				};

				$.ajax({
					type: 'POST',
					url: contextPath + '/customer/savePlace',
					contentType: 'application/json',
					data: JSON.stringify(sendData),
					beforeSend: function(xhr) {
						if (header && token) {
							xhr.setRequestHeader(header, token);
						}
					},
					success: function(res) {
						if (res && res.body === 'SUCCESS') {
							setLikeButtonState(btn, false);
							return;
						}
						if (res && res.body === 'LOGIN_REQUIRED') {
							alert('로그인이 필요한 서비스입니다.');
							location.href = contextPath + '/auth/login';
							return;
						}
						alert('찜 해제 중 오류가 발생했습니다.');
					},
					error: function(xhr) {
						if (xhr && xhr.status === 403) {
							alert('보안 토큰이 만료되었습니다. 페이지를 새로고침 해주세요.');
							return;
						}
						alert('찜 해제 중 오류가 발생했습니다.');
					}
				});
			}

			function renderPreferenceTagChips(categoryResults) {
				if (!mainPrefSub) {
					return;
				}

				mainPrefSub.innerHTML = '';
				if (!Array.isArray(categoryResults) || categoryResults.length === 0) {
					clearSelectedPreferenceTags();
					mainPrefSub.innerHTML = '<span class="main-pref-empty">선택 가능한 세부 태그가 없습니다.</span>';
					return;
				}

				categoryResults.forEach(function(group) {
					const categoryKey = group.categoryKey;
					if (!categoryKey || !selectedPreferenceCategories.has(categoryKey)) {
						return;
					}

					const groupBox = document.createElement('div');
					groupBox.className = 'main-pref-sub-group';

					const title = document.createElement('div');
					title.className = 'main-pref-sub-group-title';
					title.textContent = preferenceCategoryLabelMap[categoryKey] || categoryKey;

					const chipsWrap = document.createElement('div');
					chipsWrap.className = 'main-pref-sub-group-chips';

					const tags = Array.isArray(group.tags) ? group.tags : [];
					if (tags.length === 0) {
						const emptyText = document.createElement('span');
						emptyText.className = 'main-pref-empty';
						emptyText.textContent = '선택 가능한 세부 태그가 없습니다.';
						chipsWrap.appendChild(emptyText);
					} else {
						tags.forEach(function(tag) {
							const tagCode = tag && tag.tagCode ? String(tag.tagCode) : '';
							const tagName = tag && tag.tagName ? String(tag.tagName) : tagCode;
							if (!tagCode) {
								return;
							}

							const button = document.createElement('button');
							button.type = 'button';
							button.className = 'main-pref-chip main-pref-sub-chip';
							button.textContent = tagName;
							button.dataset.categoryKey = categoryKey;
							button.dataset.tagCode = tagCode;
							if (selectedPreferenceTags.has(tagCode)) {
								button.classList.add('active');
							}
							button.addEventListener('click', function() {
								if (selectedPreferenceTags.has(tagCode)) {
									selectedPreferenceTags.delete(tagCode);
									button.classList.remove('active');
								} else {
									Array.from(selectedPreferenceTags.entries()).forEach(function(entry) {
										const selectedTagCode = entry[0];
										const selectedInfo = entry[1];
										if (selectedInfo && selectedInfo.categoryKey === categoryKey) {
											selectedPreferenceTags.delete(selectedTagCode);
										}
									});
									chipsWrap.querySelectorAll('.main-pref-sub-chip').forEach(function(chip) {
										chip.classList.remove('active');
									});
									selectedPreferenceTags.set(tagCode, {
										categoryKey: categoryKey,
										tagName: tagName
									});
									button.classList.add('active');
								}
							});
							chipsWrap.appendChild(button);
						});
					}

					groupBox.appendChild(title);
					groupBox.appendChild(chipsWrap);
					mainPrefSub.appendChild(groupBox);
				});
			}

			function loadPreferenceTags(categoryKeys) {
				if (!mainPrefSub) {
					return;
				}

				if (!Array.isArray(categoryKeys) || categoryKeys.length === 0) {
					mainPrefSub.innerHTML = '<span class="main-pref-empty">상위 카테고리를 먼저 선택해 주세요</span>';
					return;
				}

				const requests = categoryKeys.map(function(category) {
					return fetch(contextPath + '/routes/preference-tags?category=' + encodeURIComponent(category))
						.then(function(res) {
							return res.ok ? res.json() : [];
						})
						.then(function(tags) {
							return {
								categoryKey: category,
								tags: Array.isArray(tags) ? tags : []
							};
						})
						.catch(function() {
							return {
								categoryKey: category,
								tags: []
							};
						});
				});

				Promise.all(requests)
					.then(function(results) {
						renderPreferenceTagChips(results);
					})
					.catch(function() {
						mainPrefSub.innerHTML = '<span class="main-pref-empty">세부 태그를 불러오지 못했습니다.</span>';
					});
			}

			function updatePreferenceSummary() {
				if (!mainPrefSummary) {
					return;
				}

				if (!appliedPreferenceTagCodes || appliedPreferenceTagCodes.length === 0) {
					mainPrefSummary.textContent = '';
					mainPrefSummary.classList.add('hidden');
					return;
				}

				const tagPreview = appliedPreferenceTagNames.slice(0, 3).join(', ');
				const remainingCount = appliedPreferenceTagNames.length - 3;
				const categoryPrefix = appliedPreferenceCategory
					? (preferenceCategoryLabelMap[appliedPreferenceCategory] || appliedPreferenceCategory) + ' / '
					: '';
				mainPrefSummary.textContent = '적용 중: ' + categoryPrefix + '태그 ' + appliedPreferenceTagCodes.length + '개'
					+ (tagPreview ? ' (' + tagPreview + (remainingCount > 0 ? ' 외 ' + remainingCount + '개' : '') + ')' : '');
				mainPrefSummary.classList.remove('hidden');
			}

			function applyPreferenceFilter() {
				if (selectedPreferenceTags.size === 0) {
					alert('세부 태그를 1개 이상 선택해 주세요.');
					return;
				}

				const selectedCategoryArray = Array.from(selectedPreferenceCategories);
				const selectedTagInfos = Array.from(selectedPreferenceTags.values());
				const missingCategories = selectedCategoryArray.filter(function(categoryKey) {
					return !selectedTagInfos.some(function(info) {
						return info && info.categoryKey === categoryKey;
					});
				});
				if (missingCategories.length > 0) {
					alert('선택한 상위 카테고리마다 하위 태그를 1개씩 선택해 주세요.');
					return;
				}

				appliedPreferenceCategory = selectedCategoryArray.length === 1 ? selectedCategoryArray[0] : '';
				appliedPreferenceTagCodes = Array.from(selectedPreferenceTags.keys());
				appliedPreferenceTagCode = appliedPreferenceTagCodes.join(',');
				appliedPreferenceTagNames = appliedPreferenceTagCodes.map(function(tagCode) {
					const info = selectedPreferenceTags.get(tagCode);
					return info && info.tagName ? info.tagName : tagCode;
				});
				updatePreferenceSummary();
				performSearch();
			}

			function resetPreferenceFilter() {
				selectedPreferenceCategories.clear();
				clearSelectedPreferenceTags();
				appliedPreferenceCategory = '';
				appliedPreferenceTagCode = '';
				appliedPreferenceTagCodes = [];
				appliedPreferenceTagNames = [];

				document.querySelectorAll('.main-pref-top-chip').forEach(function(chip) {
					chip.classList.remove('active');
				});
				document.querySelectorAll('.main-pref-sub-chip').forEach(function(chip) {
					chip.classList.remove('active');
				});

				if (mainPrefSub) {
					mainPrefSub.innerHTML = '<span class="main-pref-empty">상위 카테고리를 먼저 선택해 주세요</span>';
				}

				updatePreferenceSummary();
				performSearch();
			}

			if (mainPrefTop) {
				mainPrefTop.addEventListener('click', function(event) {
					const chip = event.target.closest('.main-pref-top-chip');
					if (!chip) {
						return;
					}
					const categoryKey = chip.dataset.prefCategory ? String(chip.dataset.prefCategory).trim() : '';
					if (!categoryKey) {
						return;
					}

					if (selectedPreferenceCategories.has(categoryKey)) {
						selectedPreferenceCategories.delete(categoryKey);
						chip.classList.remove('active');
					} else {
						selectedPreferenceCategories.add(categoryKey);
						chip.classList.add('active');
					}

					if (selectedPreferenceCategories.size === 0) {
						clearSelectedPreferenceTags();
						if (mainPrefSub) {
							mainPrefSub.innerHTML = '<span class="main-pref-empty">상위 카테고리를 먼저 선택해 주세요</span>';
						}
						return;
					}

					syncSelectedTagsWithCategories();
					loadPreferenceTags(Array.from(selectedPreferenceCategories));
				});
			}

			if (mainPrefApplyBtn) {
				mainPrefApplyBtn.addEventListener('click', applyPreferenceFilter);
			}
			if (mainPrefResetBtn) {
				mainPrefResetBtn.addEventListener('click', resetPreferenceFilter);
			}

			if (searchInput) {
				searchInput.addEventListener('keydown', function(e) {
					if (e.key === 'Enter') {
						e.preventDefault();
						performSearch();
					}
				});
			}

			if (nextBtn) {
				nextBtn.addEventListener('click', function() {
					const visibleCards = track ? track.querySelectorAll('.travel-card') : [];
					if (slideIndex < (visibleCards.length - 3)) {
						slideIndex += 1;
						updateSlider();
					}
				});
			}

			if (prevBtn) {
				prevBtn.addEventListener('click', function() {
					if (slideIndex > 0) {
						slideIndex -= 1;
						updateSlider();
					}
				});
			}

			document.addEventListener('click', function(e) {
				const likeBtn = e.target.closest('.like-btn');
				if (likeBtn) {
					e.preventDefault();
					e.stopPropagation();
					if (likeBtn.classList.contains('active')) {
						cancelWishlist(likeBtn);
					} else {
						openWishlistModal(likeBtn);
					}
					return;
				}

				if (wishlistModal && wishlistModal.classList.contains('is-open')) {
					const closeTarget = e.target.closest('[data-main-wishlist-close="true"]');
					if (closeTarget) {
						e.preventDefault();
						closeWishlistModal();
						return;
					}
				}

				const card = e.target.closest('.travel-card[data-place-no]');
				if (!card || !card.dataset.placeNo) {
					return;
				}

				location.href = contextPath + '/place/detail?place_no=' + encodeURIComponent(card.dataset.placeNo);
			});

			const messages = [
				'* 여행 성향은 정답보다 나에게 맞는 방향입니다.',
				'* 이번 여행에서 가장 중요하게 생각하는 감정을 떠올려보세요.',
				'* 취향이 분명할수록 실패 없는 여행이 됩니다.',
				'* 오늘의 기분으로도 충분히 좋은 여행을 만들 수 있어요.'
			];
			let msgIdx = 0;
			setInterval(function() {
				if (!textElement) {
					return;
				}
				textElement.classList.add('fade-out');
				setTimeout(function() {
					msgIdx = (msgIdx + 1) % messages.length;
					textElement.textContent = messages[msgIdx];
					textElement.classList.remove('fade-out');
				}, 400);
			}, 4000);

			if (wishlistSaveBtn) {
				wishlistSaveBtn.addEventListener('click', saveWishlistWithCategory);
			}
			if (wishlistCreateBtn) {
				wishlistCreateBtn.addEventListener('click', createWishlistCategory);
			}
			if (wishlistNewCategoryInput) {
				wishlistNewCategoryInput.addEventListener('keydown', function(event) {
					if (event.key === 'Enter') {
						event.preventDefault();
						createWishlistCategory();
					}
				});
			}
			document.addEventListener('keydown', function(event) {
				if (event.key === 'Escape' && wishlistModal && wishlistModal.classList.contains('is-open')) {
					closeWishlistModal();
				}
			});

			applyCardImages(document);
			updateSlider();
		});

		function checkLogin() {
			if (confirm('로그인이 필요한 서비스입니다. 로그인 페이지로 이동하시겠습니까?')) {
				location.href = '${pageContext.request.contextPath}/auth/login';
			}
		}
	</script>
</body>
</html>
