
// 상태 관리
const TripStatus = {
	PLANNING: 'planning',
	RECORDING: 'recording',
	COMPLETE: 'complete'
};

let currentStatus = TripStatus.PLANNING;
let places = [];
let selectedPlace = null;
let map = null;
let marker = null;
let ps = null;

// 여행 기간
let tripStartDate = '';
let tripEndDate = '';


// 현재 방문 중인 장소 인덱스 (0부터 시작, -1이면 시작 전)
let currentPlaceIndex = -1;

// DOM 요소
const addPlaceBtn = document.getElementById('addPlaceBtn');
const addPlaceSection = document.getElementById('addPlaceSection');
const mapModal = document.getElementById('mapModal');
const closeMapModal = document.getElementById('closeMapModal');
const placeSearch = document.getElementById('placeSearch');
const searchBtn = document.getElementById('searchBtn');
const searchResults = document.getElementById('searchResults');
const confirmPlace = document.getElementById('confirmPlace');
const placeList = document.getElementById('placeList');
const startTripBtn = document.getElementById('startTripBtn');
const completeTripBtn = document.getElementById('completeTripBtn');
const saveBtn = document.getElementById('saveBtn');
const statusBadge = document.getElementById('statusBadge');
const reviewSection = document.getElementById('reviewSection');

// 초기화
document.addEventListener('DOMContentLoaded', function() {
	initEventListeners();
});


// 장소 카드 렌더링 함수
function renderPlaces() {
	placeList.innerHTML = '';

	places.forEach((place, index) => {
		const card = document.createElement('div');
		card.className = 'place-card';
		card.dataset.index = index;

		// 드래그 가능 여부: 계획 중이거나, 기록 중일 때 아직 방문하지 않은 장소
		const canDrag = (currentStatus === TripStatus.PLANNING) ||
			(currentStatus === TripStatus.RECORDING && index > currentPlaceIndex);
		card.draggable = canDrag;

		if (canDrag) {
			card.classList.add('draggable');
		}

		// 기록 중 상태일 때 진행 상태 클래스 추가
		if (currentStatus === TripStatus.RECORDING) {
			if (index < currentPlaceIndex) {
				card.classList.add('visited');
			} else if (index === currentPlaceIndex) {
				card.classList.add('current');
			} else {
				card.classList.add('upcoming');
			}
		}

		// 현재 위치 라벨
		const currentLabel = (currentStatus === TripStatus.RECORDING && index === currentPlaceIndex)
			? '<span class="current-label">📍 현재 위치</span>'
			: '';

		// 드래그 가능 표시
		const dragHint = canDrag
			? '<span class="drag-hint">☰ 드래그하여 순서 변경</span>'
			: '';

		// 완료 버튼 (기록 중 + 현재 장소일 때만)
		const completeBtn = (currentStatus === TripStatus.RECORDING && index === currentPlaceIndex)
			? `<button type="button" class="complete-place-btn" onclick="completeCurrentPlace()">✓ 방문 완료</button>`
			: '';

		// 완료 상태에서도 사진/코멘트 수정 가능 여부
		const isEditable = (currentStatus !== TripStatus.PLANNING);

		card.innerHTML = `
            ${dragHint}
            ${currentLabel}
            <div class="place-name">${place.name}</div>
            <div class="place-datetime">
                <div class="datetime-row">
                    <label>방문 일시:</label>
                    <input type="date" value="${place.date || ''}"
                           onchange="updatePlace(${index}, 'date', this.value)"
                           ${currentStatus === TripStatus.COMPLETE ? 'disabled' : ''}>
                    <input type="time" value="${place.time || ''}"
                           onchange="updatePlace(${index}, 'time', this.value)"
                           ${currentStatus === TripStatus.COMPLETE ? 'disabled' : ''}>
                </div>
                <div class="datetime-row">
                    <label>종료 예정:</label>
                    <input type="date" value="${place.endDate || ''}"
                           onchange="updatePlace(${index}, 'endDate', this.value)"
                           ${currentStatus === TripStatus.COMPLETE ? 'disabled' : ''}>
                    <input type="time" value="${place.endTime || ''}"
                           onchange="updatePlace(${index}, 'endTime', this.value)"
                           ${currentStatus === TripStatus.COMPLETE ? 'disabled' : ''}>
                </div>
            </div>
            <div class="place-memo">
                <label>메모 (계획용):</label>
                <textarea placeholder="메모를 입력하세요..."
                          onchange="updatePlace(${index}, 'memo', this.value)"
                          ${currentStatus === TripStatus.COMPLETE ? 'disabled' : ''}>${place.memo || ''}</textarea>
            </div>
            ${isEditable ? renderRecordingFields(place, index) : ''}
            ${completeBtn}
            ${currentStatus !== TripStatus.COMPLETE ?
				`<button type="button" class="delete-place" onclick="deletePlace(${index})">×</button>` : ''}
        `;

		placeList.appendChild(card);
	});

	updateProgress();
	initDragAndDrop();
}


// 기록 중 필드 렌더링 (완료 상태에서도 수정 가능)
function renderRecordingFields(place, index) {
	const isComplete = (currentStatus === TripStatus.COMPLETE);

	return `
        <div class="recording-fields">
            <div class="comment-section">
                <label>📝 리뷰 코멘트:</label>
                <textarea class="place-comment" 
                          placeholder="이 장소에 대한 리뷰를 작성하세요... (방문 후기, 추천 메뉴, 팁 등)"
                          onchange="updatePlaceById(${place.id}, 'comment', this.value)"
                          rows="4">${place.comment || ''}</textarea>
            </div>
            <div class="rating-section">
                <span>별점:</span>
                <div class="star-rating" data-id="${place.id}" data-rating="${place.rating || 0}">
                    ${[1, 2, 3, 4, 5].map(i =>
		`<i class="${i <= (place.rating || 0) ? 'fas' : 'far'} fa-star"
                            data-value="${i}" onclick="setRating(${place.id}, ${i})"></i>`
	).join('')}
                </div>
            </div>
            <div class="photo-upload">
                <input type="file" id="photo-${place.id}" multiple accept="image/*"
                       onchange="handlePhotoUpload(${place.id}, this)" style="display:none;">
                <button type="button" class="upload-btn" onclick="triggerPhotoUpload(${place.id})">
                    <i class="fas fa-camera"></i> 사진 ${isComplete ? '수정' : '추가'}
                </button>
                <div class="photo-preview">
                    ${(place.photos || []).map((photo, photoIndex) => `
                        <div class="photo-item">
                            <img src="${photo}" alt="사진">
                            <button type="button" class="delete-photo-btn" onclick="deletePhoto(${place.id}, ${photoIndex})">×</button>
                        </div>
                    `).join('')}
                </div>
            </div>
        </div>
    `;
}

// 현재 장소 방문 완료
function completeCurrentPlace() {
	if (currentPlaceIndex < places.length - 1) {
		currentPlaceIndex++;
		renderPlaces();
	} else {
		// 모든 장소 방문 완료
		if (confirm('모든 장소를 방문했습니다! 여행을 완료하시겠습니까?')) {
			completeTrip();
		}
	}
}

// 진행 상황 업데이트
function updateProgress() {
	const progressSection = document.getElementById('progressSection');
	const progressText = document.getElementById('progressText');
	const progressPercent = document.getElementById('progressPercent');
	const progressFill = document.getElementById('progressFill');

	if (!progressSection) return;

	if (currentStatus === TripStatus.RECORDING && places.length > 0) {
		progressSection.classList.remove('hidden');

		const completed = currentPlaceIndex >= 0 ? currentPlaceIndex : 0;
		const total = places.length;
		const percent = Math.round((completed / total) * 100);

		progressText.textContent = `${completed} / ${total} 완료`;
		progressPercent.textContent = `${percent}%`;
		progressFill.style.width = `${percent}%`;
	} else {
		progressSection.classList.add('hidden');
	}
}

// 여행 시작
function startTrip() {
	if (places.length === 0) {
		alert('최소 1개 이상의 장소를 추가해주세요.');
		return;
	}

	currentStatus = TripStatus.RECORDING;
	document.getElementById('planStatus').value = 'RECORDING';
	currentPlaceIndex = 0;
	updateUI();
	renderPlaces();
}

// 여행 완료
function completeTrip() {
	currentStatus = TripStatus.COMPLETE;
	document.getElementById('planStatus').value = 'COMPLETED';
	updateUI();
	renderPlaces();
}

// UI 업데이트 (통합)
function updateUI() {
	const addPlaceHint = document.getElementById('addPlaceHint');
	const tripStartDateInput = document.getElementById('tripStartDate');
	const tripEndDateInput = document.getElementById('tripEndDate');

	switch (currentStatus) {
		case TripStatus.PLANNING:
			statusBadge.textContent = '계획 중';
			statusBadge.className = 'status-badge status-planning';
			addPlaceSection.classList.remove('hidden');
			if (addPlaceHint) addPlaceHint.classList.add('hidden');
			startTripBtn.classList.remove('hidden');
			completeTripBtn.classList.add('hidden');
			reviewSection.classList.add('hidden');
			if (tripStartDateInput) tripStartDateInput.readOnly = false;
			if (tripEndDateInput) tripEndDateInput.readOnly = false;
			break;
		case TripStatus.RECORDING:
			statusBadge.textContent = '기록 중';
			statusBadge.className = 'status-badge status-recording';
			addPlaceSection.classList.remove('hidden');
			if (addPlaceHint) addPlaceHint.classList.remove('hidden');
			startTripBtn.classList.add('hidden');
			completeTripBtn.classList.remove('hidden');
			reviewSection.classList.remove('hidden');
			if (tripStartDateInput) tripStartDateInput.readOnly = true;
			if (tripEndDateInput) tripEndDateInput.readOnly = true;
			break;
		case TripStatus.COMPLETE:
			statusBadge.textContent = '완료';
			statusBadge.className = 'status-badge status-complete';
			addPlaceSection.classList.add('hidden');
			startTripBtn.classList.add('hidden');
			completeTripBtn.classList.add('hidden');
			reviewSection.classList.remove('hidden');
			if (tripStartDateInput) tripStartDateInput.readOnly = true;
			if (tripEndDateInput) tripEndDateInput.readOnly = true;
			break;
	}

	updateProgress();
}

// 이벤트 리스너 초기화
function initEventListeners() {
	addPlaceBtn.addEventListener('click', openMapModal);
	closeMapModal.addEventListener('click', closeModal);
	searchBtn.addEventListener('click', searchPlace);
	placeSearch.addEventListener('keypress', function(e) {
		if (e.key === 'Enter') searchPlace();
	});
	confirmPlace.addEventListener('click', addSelectedPlace);
	startTripBtn.addEventListener('click', startTrip);
	completeTripBtn.addEventListener('click', completeTrip);
	saveBtn.addEventListener('click', savePlan);

	document.querySelectorAll('.star-rating').forEach(function(rating) {
		rating.addEventListener('click', handleStarClick);
	});
}

// 지도 모달
function openMapModal() {
	mapModal.classList.remove('hidden');
	if (!map) {
		initMap();
	}
}

function closeModal() {
	mapModal.classList.add('hidden');
	selectedPlace = null;
	searchResults.innerHTML = '';
}

// 카카오맵 초기화
function initMap() {
	var container = document.getElementById('map');
	var options = {
		center: new kakao.maps.LatLng(37.5665, 126.9780),
		level: 5
	};
	map = new kakao.maps.Map(container, options);
	ps = new kakao.maps.services.Places();
	marker = new kakao.maps.Marker();
}

// 장소 검색
function searchPlace() {
	var keyword = placeSearch.value.trim();
	if (!keyword) return;

	ps.keywordSearch(keyword, function(data, status) {
		if (status === kakao.maps.services.Status.OK) {
			displaySearchResults(data);
			var bounds = new kakao.maps.LatLngBounds();
			data.forEach(function(place) {
				bounds.extend(new kakao.maps.LatLng(place.y, place.x));
			});
			map.setBounds(bounds);
		}
	});
}

function displaySearchResults(results) {
	var html = '';
	for (var i = 0; i < results.length; i++) {
		var place = results[i];
		html += '<div class="search-result-item" data-index="' + i + '"' +
			' data-name="' + place.place_name + '"' +
			' data-address="' + place.address_name + '"' +
			' data-lat="' + place.y + '"' +
			' data-lng="' + place.x + '">' +
			'<strong>' + place.place_name + '</strong>' +
			'<div style="font-size: 12px; color: #666;">' + place.address_name + '</div>' +
			'</div>';
	}
	searchResults.innerHTML = html;

	document.querySelectorAll('.search-result-item').forEach(function(item) {
		item.addEventListener('click', function() {
			selectSearchResult(this);
		});
	});
}

function selectSearchResult(item) {
	document.querySelectorAll('.search-result-item').forEach(function(i) {
		i.style.background = '';
	});
	item.style.background = '#e8f4fd';

	var lat = parseFloat(item.dataset.lat);
	var lng = parseFloat(item.dataset.lng);
	var position = new kakao.maps.LatLng(lat, lng);

	map.setCenter(position);
	marker.setPosition(position);
	marker.setMap(map);

	selectedPlace = {
		name: item.dataset.name,
		address: item.dataset.address,
		lat: lat,
		lng: lng
	};
}


// 장소 추가
function addSelectedPlace() {
	if (!selectedPlace) {
		alert('장소를 선택해주세요.');
		return;
	}

	var place = {
		id: Date.now(),
		name: selectedPlace.name,
		address: selectedPlace.address,
		lat: selectedPlace.lat,
		lng: selectedPlace.lng,
		date: '',
		time: '',
		endDate: '',      // 종료 예정일 추가
		endTime: '',      // 종료 예정시간 추가
		memo: '',
		photos: [],
		rating: 0,
		comment: ''       // 리뷰 코멘트
	};

	places.push(place);
	renderPlaces();
	closeModal();
}

// 드래그 앤 드롭
function initDragAndDrop() {
	var cards = document.querySelectorAll('.place-card');

	cards.forEach(function(card) {
		card.addEventListener('dragstart', handleDragStart);
		card.addEventListener('dragend', handleDragEnd);
		card.addEventListener('dragover', handleDragOver);
		card.addEventListener('drop', handleDrop);
	});
}

var draggedItem = null;

function handleDragStart(e) {
	draggedItem = this;
	this.classList.add('dragging');
}

function handleDragEnd(e) {
	this.classList.remove('dragging');
}

function handleDragOver(e) {
	e.preventDefault();
}

function handleDrop(e) {
	e.preventDefault();
	if (this !== draggedItem) {
		var allCards = Array.from(placeList.querySelectorAll('.place-card'));
		var draggedIndex = allCards.indexOf(draggedItem);
		var targetIndex = allCards.indexOf(this);

		var removed = places.splice(draggedIndex, 1)[0];
		places.splice(targetIndex, 0, removed);
		renderPlaces();
	}
}

// 장소 업데이트/삭제
function updatePlace(index, field, value) {
	if (places[index]) {
		places[index][field] = value;
	}
}

function deletePlace(index) {
	if (confirm('이 장소를 삭제하시겠습니까?')) {
		places.splice(index, 1);
		// 삭제 후 현재 인덱스 조정
		if (currentPlaceIndex >= places.length) {
			currentPlaceIndex = places.length - 1;
		}
		renderPlaces();
	}
}

// 사진 삭제
function deletePhoto(placeId, photoIndex) {
	var place = places.find(function(p) { return p.id === placeId; });
	if (place && place.photos) {
		place.photos.splice(photoIndex, 1);
		renderPlaces();
		updatePhotoSelector();
	}
}

// ID로 장소 업데이트
function updatePlaceById(id, field, value) {
	var place = places.find(function(p) { return p.id === id; });
	if (place) {
		place[field] = value;
	}
}

// 사진 업로드
function triggerPhotoUpload(id) {
	document.getElementById('photo-' + id).click();
}

function handlePhotoUpload(id, input) {
	var place = places.find(function(p) { return p.id === id; });
	if (!place) return;

	var files = input.files;
	for (var i = 0; i < files.length; i++) {
		var file = files[i];
		var reader = new FileReader();
		reader.onload = function(e) {
			place.photos.push(e.target.result);
			renderPlaces();
			updatePhotoSelector();
		};
		reader.readAsDataURL(file);
	}
}

// 별점
function setRating(id, value) {
	var place = places.find(function(p) { return p.id === id; });
	if (place) {
		place.rating = value;
		renderPlaces();
	}
}

function handleStarClick(e) {
	if (e.target.tagName === 'I') {
		var value = parseInt(e.target.dataset.value);
		var container = e.target.parentElement;
		container.dataset.rating = value;
		var stars = container.querySelectorAll('i');
		for (var i = 0; i < stars.length; i++) {
			stars[i].className = i < value ? 'fas fa-star' : 'far fa-star';
		}
	}
}

function updatePhotoSelector() {
	var selector = document.getElementById('photoSelector');
	if (!selector) return;

	var allPhotos = [];
	for (var i = 0; i < places.length; i++) {
		allPhotos = allPhotos.concat(places[i].photos || []);
	}
	var html = '';
	for (var j = 0; j < allPhotos.length; j++) {
		html += '<img src="' + allPhotos[j] + '" onclick="this.classList.toggle(\'selected\')">';
	}
	selector.innerHTML = html;
}


// 여행 기간 업데이트
function updateTripPeriod() {
	const startInput = document.getElementById('tripStartDate');
	const endInput = document.getElementById('tripEndDate');
	const summary = document.getElementById('periodSummary');

	tripStartDate = startInput.value;
	tripEndDate = endInput.value;

	// 종료일이 시작일보다 빠르면 경고
	if (tripStartDate && tripEndDate && tripStartDate > tripEndDate) {
		alert('종료일은 시작일보다 늦어야 합니다.');
		endInput.value = '';
		tripEndDate = '';
		return;
	}

	// 기간 요약 표시
	if (tripStartDate && tripEndDate) {
		const start = new Date(tripStartDate);
		const end = new Date(tripEndDate);
		const diffTime = Math.abs(end - start);
		const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
		const nights = diffDays - 1;

		summary.innerHTML = `
            <span class="period-days">${nights}박 ${diffDays}일</span>
            <span class="period-text">${formatDate(tripStartDate)} ~ ${formatDate(tripEndDate)}</span>
        `;
		summary.classList.remove('hidden');
	} else {
		summary.classList.add('hidden');
	}
}

// 날짜 포맷팅 (YYYY-MM-DD → M월 D일)
function formatDate(dateStr) {
	if (!dateStr) return '';
	const date = new Date(dateStr);
	return `${date.getMonth() + 1}월 ${date.getDate()}일`;
}


// 저장
function savePlan() {
		
	var totalStarsEl = document.getElementById('totalStars');
	var totalReviewEl = document.getElementById('totalReview');

	var data = {
		title: document.getElementById('tripTitle').value,
		startDate: tripStartDate,      
		endDate: tripEndDate,          
		status: currentStatus,
		isPublic: document.getElementById('isPublic').checked,
		places: places,
		totalRating: totalStarsEl ? totalStarsEl.dataset.rating : 0,
		totalReview: totalReviewEl ? totalReviewEl.value : ''
	};

	console.log('저장 데이터:', data);
	alert('저장되었습니다.');
}
