const TripStatus = {
    PLANNING: 'PLANNING',
    RECORDING: 'RECORDING',
    COMPLETED: 'COMPLETED'
};

let currentStatus = TripStatus.PLANNING;
let places = [];
let selectedPlace = null;
let map = null;
let marker = null;
let placeService = null;
let draggedIndex = null;

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
const planForm = document.getElementById('planForm');
const planDetailsJsonInput = document.getElementById('planDetailsJson');
const contextPath = (typeof window !== 'undefined' && window.appContextPath) ? window.appContextPath : '';

document.addEventListener('DOMContentLoaded', function () {
    bindEvents();
    loadInitialData();
    updateUI();
    renderPlaces();
    updateTripPeriod();
});

function bindEvents() {
    if (addPlaceBtn) addPlaceBtn.addEventListener('click', openMapModal);
    if (closeMapModal) closeMapModal.addEventListener('click', closeModal);
    if (searchBtn) searchBtn.addEventListener('click', searchPlace);
    if (placeSearch) {
        placeSearch.addEventListener('keypress', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                searchPlace();
            }
        });
    }
    if (confirmPlace) confirmPlace.addEventListener('click', addSelectedPlace);
    if (startTripBtn) startTripBtn.addEventListener('click', startTrip);
    if (completeTripBtn) completeTripBtn.addEventListener('click', completeTrip);
    if (saveBtn) saveBtn.addEventListener('click', savePlan);
}

function loadInitialData() {
    const statusInput = document.getElementById('planStatus');
    if (statusInput && statusInput.value) {
        const status = String(statusInput.value).toUpperCase();
        if (TripStatus[status]) {
            currentStatus = TripStatus[status];
        } else if (status === 'PLANNING' || status === 'RECORDING' || status === 'COMPLETED') {
            currentStatus = status;
        }
    }

    const initialDataElement = document.getElementById('initial-plan-data');
    if (!initialDataElement) {
        places = [];
        return;
    }

    let parsed = [];
    try {
        const raw = (initialDataElement.textContent || '').trim();
        parsed = raw ? JSON.parse(raw) : [];
    } catch (e) {
        parsed = [];
    }

    if (!Array.isArray(parsed)) {
        parsed = [];
    }

    places = parsed.map(function (item, idx) {
        return {
            id: Date.now() + idx,
            placeNo: item && item.placeNo ? Number(item.placeNo) : null,
            name: item && item.placeName ? String(item.placeName) : '장소',
            address: item && item.placeAddress ? String(item.placeAddress) : '',
            lat: item && item.placeLatitude ? Number(item.placeLatitude) : null,
            lng: item && item.placeLongitude ? Number(item.placeLongitude) : null,
            date: item && item.date ? String(item.date) : '',
            time: item && item.time ? String(item.time) : '',
            endDate: item && item.endDate ? String(item.endDate) : '',
            endTime: item && item.endTime ? String(item.endTime) : '',
            memo: item && item.memo ? String(item.memo) : ''
        };
    });
}

function openMapModal() {
    if (!mapModal) return;
    mapModal.classList.remove('hidden');
    if (!map) {
        initMap();
    }
}

function closeModal() {
    if (!mapModal) return;
    mapModal.classList.add('hidden');
    selectedPlace = null;
    if (searchResults) searchResults.innerHTML = '';
}

function initMap() {
    if (!window.kakao || !window.kakao.maps || !window.kakao.maps.services) {
        alert('카카오맵 스크립트를 불러오지 못했습니다.');
        return;
    }

    const container = document.getElementById('map');
    if (!container) return;

    const options = {
        center: new kakao.maps.LatLng(37.5665, 126.9780),
        level: 5
    };

    map = new kakao.maps.Map(container, options);
    marker = new kakao.maps.Marker();
    placeService = new kakao.maps.services.Places();
}

function searchPlace() {
    if (!placeService) {
        initMap();
    }
    if (!placeService) return;

    const keyword = placeSearch ? placeSearch.value.trim() : '';
    if (!keyword) return;

    placeService.keywordSearch(keyword, function (data, status) {
        if (status !== kakao.maps.services.Status.OK || !Array.isArray(data)) {
            if (searchResults) searchResults.innerHTML = '<div class="search-result-item">검색 결과가 없습니다.</div>';
            return;
        }

        renderSearchResults(data);

        const bounds = new kakao.maps.LatLngBounds();
        data.forEach(function (item) {
            bounds.extend(new kakao.maps.LatLng(Number(item.y), Number(item.x)));
        });
        map.setBounds(bounds);
    });
}

function renderSearchResults(results) {
    if (!searchResults) return;

    searchResults.innerHTML = results.map(function (item, index) {
        return ''
            + '<div class="search-result-item" data-index="' + index + '" '
            + 'data-name="' + escapeHtml(item.place_name || '') + '" '
            + 'data-address="' + escapeHtml(item.road_address_name || item.address_name || '') + '" '
            + 'data-lat="' + escapeHtml(String(item.y || '')) + '" '
            + 'data-lng="' + escapeHtml(String(item.x || '')) + '">' 
            + '<strong>' + escapeHtml(item.place_name || '장소') + '</strong>'
            + '<div style="font-size:12px; color:#64748b;">' + escapeHtml(item.road_address_name || item.address_name || '') + '</div>'
            + '</div>';
    }).join('');

    searchResults.querySelectorAll('.search-result-item').forEach(function (el) {
        el.addEventListener('click', function () {
            selectSearchResult(el);
        });
    });
}

function selectSearchResult(itemEl) {
    searchResults.querySelectorAll('.search-result-item').forEach(function (el) {
        el.style.background = '';
    });
    itemEl.style.background = '#e8f4fd';

    const lat = Number(itemEl.dataset.lat);
    const lng = Number(itemEl.dataset.lng);
    const position = new kakao.maps.LatLng(lat, lng);

    map.setCenter(position);
    marker.setPosition(position);
    marker.setMap(map);

    selectedPlace = {
        placeNo: null,
        name: itemEl.dataset.name || '',
        address: itemEl.dataset.address || '',
        lat: lat,
        lng: lng
    };
}

function addSelectedPlace() {
    if (!selectedPlace) {
        alert('장소를 먼저 선택해 주세요.');
        return;
    }

    places.push({
        id: Date.now(),
        placeNo: selectedPlace.placeNo,
        name: selectedPlace.name || '장소',
        address: selectedPlace.address || '',
        lat: selectedPlace.lat,
        lng: selectedPlace.lng,
        date: '',
        time: '',
        endDate: '',
        endTime: '',
        memo: ''
    });

    renderPlaces();
    closeModal();
}

function renderPlaces() {
    if (!placeList) return;

    placeList.innerHTML = '';

    places.forEach(function (place, index) {
        const card = document.createElement('div');
        card.className = 'place-card';
        card.draggable = currentStatus === TripStatus.PLANNING;
        card.dataset.index = String(index);

        const addressLine = place.address ? '<div style="font-size:12px;color:#64748b;margin-bottom:8px;">' + escapeHtml(place.address) + '</div>' : '';
        const placeNameHtml = place.placeNo
            ? '<button type="button" class="place-name place-link" onclick="openPlaceDetail(event, ' + Number(place.placeNo) + ')">' + escapeHtml(place.name || '장소') + '</button>'
            : '<div class="place-name">' + escapeHtml(place.name || '장소') + '</div>';

        card.innerHTML = ''
            + '<span class="drag-hint">드래그해서 순서를 바꿀 수 있습니다.</span>'
            + placeNameHtml
            + addressLine
            + '<div class="place-datetime">'
            + '  <div class="datetime-row">'
            + '    <label>방문 날짜</label>'
            + '    <input type="date" value="' + escapeHtml(place.date || '') + '" onchange="updatePlace(' + index + ', \"date\", this.value)">'
            + '    <input type="time" value="' + escapeHtml(place.time || '') + '" onchange="updatePlace(' + index + ', \"time\", this.value)">'
            + '  </div>'
            + '  <div class="datetime-row">'
            + '    <label>종료 일정</label>'
            + '    <input type="date" value="' + escapeHtml(place.endDate || '') + '" onchange="updatePlace(' + index + ', \"endDate\", this.value)">'
            + '    <input type="time" value="' + escapeHtml(place.endTime || '') + '" onchange="updatePlace(' + index + ', \"endTime\", this.value)">'
            + '  </div>'
            + '</div>'
            + '<div class="place-memo">'
            + '  <label>메모</label>'
            + '  <textarea placeholder="이 장소에 대한 메모를 입력해 주세요." onchange="updatePlace(' + index + ', \"memo\", this.value)">' + escapeHtml(place.memo || '') + '</textarea>'
            + '</div>'
            + '<button type="button" class="delete-place" onclick="deletePlace(' + index + ')">×</button>';

        card.addEventListener('dragstart', onDragStart);
        card.addEventListener('dragover', onDragOver);
        card.addEventListener('drop', onDrop);

        placeList.appendChild(card);
    });

    updateProgress();
}

function onDragStart(event) {
    draggedIndex = Number(event.currentTarget.dataset.index);
    event.currentTarget.classList.add('dragging');
}

function onDragOver(event) {
    event.preventDefault();
}

function onDrop(event) {
    event.preventDefault();
    const targetIndex = Number(event.currentTarget.dataset.index);

    document.querySelectorAll('.place-card.dragging').forEach(function (el) {
        el.classList.remove('dragging');
    });

    if (!Number.isInteger(draggedIndex) || draggedIndex === targetIndex) {
        draggedIndex = null;
        return;
    }

    const moved = places.splice(draggedIndex, 1)[0];
    places.splice(targetIndex, 0, moved);
    draggedIndex = null;
    renderPlaces();
}

function updatePlace(index, key, value) {
    if (!places[index]) return;
    places[index][key] = value;
}

function deletePlace(index) {
    if (!places[index]) return;
    if (!confirm('이 장소를 삭제하시겠습니까?')) return;
    places.splice(index, 1);
    renderPlaces();
}

function startTrip() {
    if (!Array.isArray(places) || places.length === 0) {
        alert('최소 1개 이상의 장소를 추가해 주세요.');
        return;
    }
    currentStatus = TripStatus.RECORDING;
    document.getElementById('planStatus').value = TripStatus.RECORDING;
    updateUI();
}

function completeTrip() {
    currentStatus = TripStatus.COMPLETED;
    document.getElementById('planStatus').value = TripStatus.COMPLETED;
    updateUI();
}

function updateUI() {
    if (!statusBadge) return;

    if (currentStatus === TripStatus.PLANNING) {
        statusBadge.textContent = '계획 중';
        statusBadge.className = 'status-badge status-planning';
        if (addPlaceSection) addPlaceSection.classList.remove('hidden');
        if (startTripBtn) startTripBtn.classList.remove('hidden');
        if (completeTripBtn) completeTripBtn.classList.add('hidden');
        if (reviewSection) reviewSection.classList.add('hidden');
    } else if (currentStatus === TripStatus.RECORDING) {
        statusBadge.textContent = '기록 중';
        statusBadge.className = 'status-badge status-recording';
        if (addPlaceSection) addPlaceSection.classList.remove('hidden');
        if (startTripBtn) startTripBtn.classList.add('hidden');
        if (completeTripBtn) completeTripBtn.classList.remove('hidden');
        if (reviewSection) reviewSection.classList.remove('hidden');
    } else {
        statusBadge.textContent = '완료';
        statusBadge.className = 'status-badge status-complete';
        if (addPlaceSection) addPlaceSection.classList.add('hidden');
        if (startTripBtn) startTripBtn.classList.add('hidden');
        if (completeTripBtn) completeTripBtn.classList.add('hidden');
        if (reviewSection) reviewSection.classList.remove('hidden');
    }

    updateProgress();
}

function updateProgress() {
    const progressSection = document.getElementById('progressSection');
    const progressText = document.getElementById('progressText');
    const progressPercent = document.getElementById('progressPercent');
    const progressFill = document.getElementById('progressFill');

    if (!progressSection || !progressText || !progressPercent || !progressFill) return;

    if (!Array.isArray(places) || places.length === 0) {
        progressSection.classList.add('hidden');
        return;
    }

    if (currentStatus !== TripStatus.RECORDING && currentStatus !== TripStatus.COMPLETED) {
        progressSection.classList.add('hidden');
        return;
    }

    progressSection.classList.remove('hidden');
    const completedCount = currentStatus === TripStatus.COMPLETED ? places.length : 0;
    const percent = Math.round((completedCount / places.length) * 100);
    progressText.textContent = completedCount + ' / ' + places.length + ' 완료';
    progressPercent.textContent = percent + '%';
    progressFill.style.width = percent + '%';
}

function updateTripPeriod() {
    const startInput = document.getElementById('tripStartDate');
    const endInput = document.getElementById('tripEndDate');
    const summary = document.getElementById('periodSummary');
    if (!startInput || !endInput || !summary) return;

    const start = startInput.value;
    const end = endInput.value;

    if (start && end && start > end) {
        alert('종료일이 시작일보다 빠릅니다.');
        endInput.value = '';
        summary.classList.add('hidden');
        return;
    }

    if (!start || !end) {
        summary.classList.add('hidden');
        return;
    }

    const startDate = new Date(start);
    const endDate = new Date(end);
    const diffDays = Math.floor((endDate - startDate) / (1000 * 60 * 60 * 24)) + 1;
    const nights = Math.max(diffDays - 1, 0);

    summary.innerHTML = '<span class="period-days">' + nights + '박 ' + diffDays + '일</span>'
        + '<span class="period-text">' + formatDate(start) + ' ~ ' + formatDate(end) + '</span>';
    summary.classList.remove('hidden');
}

function formatDate(dateValue) {
    if (!dateValue) return '';
    const d = new Date(dateValue);
    return (d.getMonth() + 1) + '월 ' + d.getDate() + '일';
}

function savePlan(event) {
    if (event) event.preventDefault();

    if (!planForm || !planDetailsJsonInput) {
        alert('일정 저장에 필요한 정보를 찾을 수 없습니다.');
        return;
    }

    const titleInput = document.getElementById('tripTitle');
    if (!titleInput || !titleInput.value || !titleInput.value.trim()) {
        alert('여행 제목을 입력해 주세요.');
        if (titleInput) titleInput.focus();
        return;
    }

    if (!Array.isArray(places) || places.length === 0) {
        alert('일정에 장소를 최소 1개 이상 추가해 주세요.');
        return;
    }

    const payload = places.map(function (place) {
        return {
            placeNo: place.placeNo || null,
            placeName: place.name || '',
            placeAddress: place.address || '',
            placeLatitude: place.lat || null,
            placeLongitude: place.lng || null,
            date: place.date || '',
            endDate: place.endDate || '',
            memo: place.memo || ''
        };
    });

    planDetailsJsonInput.value = JSON.stringify(payload);
    planForm.submit();
}

function openPlaceDetail(event, placeNo) {
    if (event && typeof event.stopPropagation === 'function') {
        event.stopPropagation();
    }
    if (!placeNo) return;
    location.href = contextPath + '/place/detail?place_no=' + encodeURIComponent(placeNo);
}

function escapeHtml(value) {
    return String(value || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

window.updatePlace = updatePlace;
window.deletePlace = deletePlace;
window.completeTrip = completeTrip;
window.savePlan = savePlan;
window.updateTripPeriod = updateTripPeriod;
window.openPlaceDetail = openPlaceDetail;
