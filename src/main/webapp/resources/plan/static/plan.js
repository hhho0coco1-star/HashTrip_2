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

    // 별점 이벤트
    document.querySelectorAll('.star-rating').forEach(function(rating) {
        rating.addEventListener('click', handleStarClick);
    });
}

// 지도 모달 열기
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
        startDate: '',
        endDate: '',
        memo: '',
        photos: [],
        rating: 0,
        comment: ''
    };

    places.push(place);
    renderPlaces();
    closeModal();
}

function renderPlaces() {
    var html = '';

    for (var i = 0; i < places.length; i++) {
        var place = places[i];
        var isComplete = currentStatus === TripStatus.COMPLETE;
        var disabledAttr = isComplete ? 'disabled' : '';

        html += '<div class="place-card" draggable="true" data-id="' + place.id + '">';
        html += '<button class="delete-place" onclick="deletePlace(' + place.id + ')">×</button>';
        html += '<div class="place-name">';
        html += '<i class="fas fa-map-marker-alt" style="color: #667eea;"></i> ';
        html += place.name;
        html += '</div>';
        html += '<div style="font-size: 12px; color: #666; margin-bottom: 10px;">';
        html += place.address;
        html += '</div>';

        html += '<div class="place-datetime">';
        html += '<div>';
        html += '<label>시작</label>';
        html += '<input type="datetime-local" value="' + place.startDate + '" ';
        html += 'onchange="updatePlace(' + place.id + ', \'startDate\', this.value)" ' + disabledAttr + '>';
        html += '</div>';
        html += '<div>';
        html += '<label>종료</label>';
        html += '<input type="datetime-local" value="' + place.endDate + '" ';
        html += 'onchange="updatePlace(' + place.id + ', \'endDate\', this.value)" ' + disabledAttr + '>';
        html += '</div>';
        html += '</div>';

        html += '<div class="place-memo">';
        html += '<textarea placeholder="메모를 입력하세요" ';
        html += 'onchange="updatePlace(' + place.id + ', \'memo\', this.value)" ' + disabledAttr + '>';
        html += place.memo + '</textarea>';
        html += '</div>';

        // 기록 모드일 때만 사진/평점/코멘트 표시
        if (currentStatus !== TripStatus.PLANNING) {
            // 사진 업로드
            html += '<div class="place-photos">';
            html += '<div class="photo-upload-area" onclick="triggerPhotoUpload(' + place.id + ')">';
            html += '<i class="fas fa-camera"></i> 사진 추가';
            html += '<input type="file" id="photo-' + place.id + '" multiple accept="image/*" ';
            html += 'onchange="handlePhotoUpload(' + place.id + ', this)" style="display:none;">';
            html += '</div>';
            html += '<div class="photo-preview" id="preview-' + place.id + '">';
            for (var j = 0; j < place.photos.length; j++) {
                html += '<img src="' + place.photos[j] + '" alt="photo">';
            }
            html += '</div>';
            html += '</div>';

            // 평점
            html += '<div class="place-rating">';
            html += '<span>평점</span>';
            html += '<div class="star-rating" data-id="' + place.id + '" data-rating="' + place.rating + '">';
            for (var k = 1; k <= 5; k++) {
                var starClass = k <= place.rating ? 'fas' : 'far';
                html += '<i class="' + starClass + ' fa-star" data-value="' + k + '" ';
                html += 'onclick="setRating(' + place.id + ', ' + k + ')"></i>';
            }
            html += '</div>';
            html += '</div>';

            // 코멘트
            html += '<div class="place-comment">';
            html += '<textarea placeholder="코멘트를 작성하세요" ';
            html += 'onchange="updatePlace(' + place.id + ', \'comment\', this.value)">';
            html += place.comment + '</textarea>';
            html += '</div>';
        }

        html += '</div>';
    }

    placeList.innerHTML = html;
    initDragAndDrop();
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
function updatePlace(id, field, value) {
    var place = places.find(function(p) { return p.id === id; });
    if (place) place[field] = value;
}

function deletePlace(id) {
    if (confirm('이 장소를 삭제하시겠습니까?')) {
        places = places.filter(function(p) { return p.id !== id; });
        renderPlaces();
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

// 상태 전환
function startTrip() {
    if (places.length === 0) {
        alert('최소 1개 이상의 장소를 추가해주세요.');
        return;
    }

    currentStatus = TripStatus.RECORDING;
    updateUI();
    renderPlaces();
}

function completeTrip() {
    currentStatus = TripStatus.COMPLETE;
    updateUI();
    renderPlaces();
}

function updateUI() {
    switch (currentStatus) {
        case TripStatus.PLANNING:
            statusBadge.textContent = '계획 중';
            statusBadge.className = 'status-badge status-planning';
            addPlaceSection.classList.remove('hidden');
            startTripBtn.classList.remove('hidden');
            completeTripBtn.classList.add('hidden');
            reviewSection.classList.add('hidden');
            break;
        case TripStatus.RECORDING:
            statusBadge.textContent = '기록 중';
            statusBadge.className = 'status-badge status-recording';
            addPlaceSection.classList.add('hidden');
            startTripBtn.classList.add('hidden');
            completeTripBtn.classList.remove('hidden');
            reviewSection.classList.remove('hidden');
            break;
        case TripStatus.COMPLETE:
            statusBadge.textContent = '완료';
            statusBadge.className = 'status-badge status-complete';
            addPlaceSection.classList.add('hidden');
            startTripBtn.classList.add('hidden');
            completeTripBtn.classList.add('hidden');
            reviewSection.classList.remove('hidden');
            break;
    }
}

function updatePhotoSelector() {
    var selector = document.getElementById('photoSelector');
    var allPhotos = [];
    for (var i = 0; i < places.length; i++) {
        allPhotos = allPhotos.concat(places[i].photos);
    }
    var html = '';
    for (var j = 0; j < allPhotos.length; j++) {
        html += '<img src="' + allPhotos[j] + '" onclick="this.classList.toggle(\'selected\')">';
    }
    selector.innerHTML = html;
}

// 저장
function savePlan() {
    var totalStarsEl = document.getElementById('totalStars');
    var totalReviewEl = document.getElementById('totalReview');

    var data = {
        title: document.getElementById('tripTitle').value,
        status: currentStatus,
        isPublic: document.getElementById('isPublic').checked,
        places: places,
        totalRating: totalStarsEl ? totalStarsEl.dataset.rating : 0,
        totalReview: totalReviewEl ? totalReviewEl.value : ''
    };

    console.log('저장 데이터:', data);
    alert('저장되었습니다.');

    // TODO: AJAX로 서버에 전송
    // fetch('/plan/save', {
    //     method: 'POST',
    //     headers: { 'Content-Type': 'application/json' },
    //     body: JSON.stringify(data)
    // });
}