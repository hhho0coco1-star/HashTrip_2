(function () {
    "use strict";
    const ctx = typeof window.appContextPath !== "undefined" ? window.appContextPath : "";
    let places = [];
    let selectedPlace = null;
    let map = null;
    let marker = null;
    let placeService = null;
    let mapReady = false;
    let draggedId = null;
    let replacePlaceId = null;
    let replaceNearbyList = [];
    let selectedReplaceIdx = -1;
    let replaceMapInstance = null;
    let replaceMarkers = [];
    let replaceCurrentOverlay = null;

    function id(s) { return document.getElementById(s); }
    function qs(s, r) { return (r || document).querySelector(s); }
    function qsAll(s, r) { return Array.from((r || document).querySelectorAll(s)); }

    function loadInitial() {
        const el = id("initial-plan-data");
        if (!el || !el.textContent) return;
        try {
            const raw = (el.textContent || "").trim();
            places = raw ? JSON.parse(raw) : [];
        } catch (e) {
            places = [];
        }
        places.forEach(function (p, i) {
            if (!p.id) p.id = (p.planDetailNo ? "pd_" + p.planDetailNo : "p_" + Date.now() + "_" + i);
        });
    }

    function createPlaceId() {
        return "p_" + Date.now() + "_" + Math.random().toString(36).slice(2);
    }

    function getPlanStartDate() {
        const input = id("planStartDate");
        return input && input.value ? input.value : "";
    }

    function getPlanEndDate() {
        const input = id("planEndDate");
        return input && input.value ? input.value : "";
    }

    function getPlanDayCount() {
        const startStr = getPlanStartDate();
        const endStr = getPlanEndDate();
        if (!startStr || !endStr) return 1;
        const start = new Date(startStr);
        const end = new Date(endStr);
        const diff = Math.round((end - start) / (24 * 60 * 60 * 1000)) + 1;
        return Math.max(1, diff);
    }

    function dateStrAddDays(dateStr, days) {
        if (!dateStr) return "";
        const d = new Date(dateStr);
        d.setDate(d.getDate() + days);
        return d.toISOString().slice(0, 10);
    }

    function render() {
        recalcDayNumbers();
        const container = id("placeListByDay");
        if (!container) return;
        const startStr = getPlanStartDate();
        const numDays = getPlanDayCount();
        const byDay = {};
        for (var d = 1; d <= numDays; d++) byDay[d] = [];
        places.forEach(function (p) {
            const dayNum = Math.min(numDays, Math.max(1, p.dayNumber || 1));
            if (!byDay[dayNum]) byDay[dayNum] = [];
            byDay[dayNum].push(p);
        });
        const days = [];
        for (var i = 1; i <= numDays; i++) days.push(i);
        container.innerHTML = days.map(function (dayNum) {
            const list = byDay[dayNum] || [];
            const cards = list.map(function (p) {
                const name = escapeHtml(p.placeName || "장소");
                const link = p.placeNo
                    ? "<a href=\"" + ctx + "/place/detail?place_no=" + p.placeNo + "\" class=\"planner-place-name-link\">" + name + "</a>"
                    : "<span class=\"planner-place-name\">" + name + "</span>";
                return "<div class=\"planner-card\" draggable=\"true\" data-place-id=\"" + (p.id || "") + "\">" +
                    "<span class=\"planner-drag-handle\">≡</span>" +
                    link +
                    (p.placeAddress ? "<div class=\"planner-place-addr\">" + escapeHtml(p.placeAddress) + "</div>" : "") +
                    "<div class=\"planner-card-memo\"><label>메모</label><textarea data-field=\"memo\" data-id=\"" + (p.id || "") + "\">" + escapeHtml(p.memo || "") + "</textarea></div>" +
                    "<div class=\"planner-card-day-hint\">" + (dayNum || 1) + "일차</div>" +
                    "<button type=\"button\" class=\"planner-btn-change\" data-place-id=\"" + (p.id || "") + "\">변경</button>" +
                    "<button type=\"button\" class=\"planner-btn-remove\" data-place-id=\"" + (p.id || "") + "\">삭제</button>" +
                    "</div>";
            }).join("");
            const dayDate = dateStrAddDays(startStr, dayNum - 1);
            let dayTitle = dayNum + "일차";
            if (dayDate) {
                const d = new Date(dayDate);
                if (!isNaN(d.getTime())) {
                    const mm = d.getMonth() + 1;
                    const dd = d.getDate();
                    dayTitle += " (" + mm + "/" + dd + ")";
                }
            }
            const emptyHint = list.length === 0 ? "<p class=\"planner-day-empty-hint\">장소를 여기로 드래그하세요</p>" : "";
            return "<div class=\"planner-day-group planner-day-dropzone\" data-day=\"" + dayNum + "\" data-date=\"" + (dayDate || "") + "\">" +
                "<h3 class=\"planner-day-title\">" + dayTitle + "</h3>" +
                "<div class=\"planner-day-cards\">" + cards + emptyHint + "</div>" +
                "</div>";
        }).join("");

        qsAll("[data-field]", container).forEach(function (el) {
            el.addEventListener("input", function () {
                const pid = el.getAttribute("data-id");
                const field = el.getAttribute("data-field");
                const place = places.find(function (p) { return String(p.id) === String(pid); });
                if (place && field) {
                    place[field] = el.value;
                    if (field === "date") {
                        recalcDayNumbers();
                        render();
                    }
                }
            });
        });
        qsAll(".planner-btn-remove", container).forEach(function (btn) {
            btn.addEventListener("click", function () {
                const pid = btn.getAttribute("data-place-id");
                if (!confirm("이 장소를 삭제할까요?")) return;
                places = places.filter(function (p) { return String(p.id) !== String(pid); });
                render();
            });
        });
        qsAll(".planner-btn-change", container).forEach(function (btn) {
            btn.addEventListener("click", function () {
                replacePlaceId = btn.getAttribute("data-place-id");
                openReplaceModal();
            });
        });
        qsAll(".planner-card", container).forEach(function (card) {
            card.addEventListener("dragstart", onDragStart);
            card.addEventListener("dragend", function () { card.classList.remove("planner-dragging"); });
            card.addEventListener("dragover", onDragOver);
            card.addEventListener("drop", onDrop);
        });
        qsAll(".planner-day-dropzone", container).forEach(function (zone) {
            zone.addEventListener("dragover", function (e) {
                e.preventDefault();
                if (draggedId) zone.classList.add("planner-drag-over");
            });
            zone.addEventListener("dragleave", function (e) {
                if (!zone.contains(e.relatedTarget)) zone.classList.remove("planner-drag-over");
            });
            zone.addEventListener("drop", onDropDayZone);
        });
    }

    function onDragStart(e) {
        draggedId = e.currentTarget.getAttribute("data-place-id");
        e.currentTarget.classList.add("planner-dragging");
    }
    function onDragOver(e) {
        e.preventDefault();
    }
    function onDrop(e) {
        e.preventDefault();
        const target = e.currentTarget;
        if (target.classList.contains("planner-day-dropzone")) return;
        target.classList.remove("planner-dragging");
        const targetId = target.getAttribute("data-place-id");
        if (!draggedId || !targetId || draggedId === targetId) {
            draggedId = null;
            return;
        }
        const fromIdx = places.findIndex(function (p) { return String(p.id) === String(draggedId); });
        const toIdx = places.findIndex(function (p) { return String(p.id) === String(targetId); });
        if (fromIdx < 0 || toIdx < 0) {
            draggedId = null;
            return;
        }
        const moved = places.splice(fromIdx, 1)[0];
        const targetPlace = places[toIdx];
        if (targetPlace && targetPlace.date) {
            moved.date = targetPlace.date;
            moved.dayNumber = targetPlace.dayNumber || 1;
        }
        places.splice(toIdx, 0, moved);
        draggedId = null;
        render();
    }

    function onDropDayZone(e) {
        e.preventDefault();
        e.stopPropagation();
        const zone = e.currentTarget;
        zone.classList.remove("planner-drag-over");
        const dayNum = parseInt(zone.getAttribute("data-day"), 10);
        const dayDate = zone.getAttribute("data-date");
        if (!draggedId || !dayDate) {
            draggedId = null;
            return;
        }
        const place = places.find(function (p) { return String(p.id) === String(draggedId); });
        if (place) {
            place.date = dayDate;
            place.dayNumber = dayNum;
        }
        draggedId = null;
        render();
    }

    function openReplaceModal() {
        const modal = id("replaceModal");
        const list = id("replacePlaceList");
        if (!modal || !list) return;
        const place = places.find(function (p) { return String(p.id) === String(replacePlaceId); });
        if (!place) return;
        const lat = place.placeLatitude != null ? parseFloat(place.placeLatitude) : NaN;
        const lng = place.placeLongitude != null ? parseFloat(place.placeLongitude) : NaN;
        if (isNaN(lat) || isNaN(lng)) {
            list.innerHTML = "<p class=\"planner-replace-msg\">이 장소에는 위치 정보가 없어 근처 여행지를 검색할 수 없습니다. 장소 추가로 새 장소를 넣은 뒤 순서를 바꿔 보세요.</p>";
            modal.classList.remove("hidden");
            return;
        }
        list.innerHTML = "<p class=\"planner-replace-msg\">검색 중...</p>";
        modal.classList.remove("hidden");
        fetchReplacePlaces();
    }

    function fetchReplacePlaces() {
        const list = id("replacePlaceList");
        const place = places.find(function (p) { return String(p.id) === String(replacePlaceId); });
        if (!list || !place) return;
        const lat = parseFloat(place.placeLatitude);
        const lng = parseFloat(place.placeLongitude);
        const radiusEl = id("replaceRadius");
        const radiusKm = radiusEl ? Math.max(1, Math.min(50, parseInt(radiusEl.value, 10) || 10)) : 10;
        const excludePlaceNo = place.placeNo || null;
        const url = ctx + "/planner/nearby-places?lat=" + encodeURIComponent(lat) + "&lng=" + encodeURIComponent(lng) + "&radiusKm=" + radiusKm + (excludePlaceNo ? "&excludePlaceNo=" + excludePlaceNo : "");
        fetch(url, { credentials: "same-origin" })
            .then(function (res) { return res.ok ? res.json() : []; })
            .then(function (arr) {
                replaceNearbyList = Array.isArray(arr) ? arr : [];
                const mapEl = id("replaceMap");
                if (replaceNearbyList.length === 0) {
                    selectedReplaceIdx = -1;
                    updateReplaceConfirmButton();
                    loadReplacePlacePreview(null);
                    if (mapEl) mapEl.classList.add("hidden");
                    list.innerHTML = "<p class=\"planner-replace-msg\">반경 " + radiusKm + " km 안에 다른 여행지가 없습니다. 반경을 늘려 보세요.</p>";
                    return;
                }
                ensureReplaceMapReady().then(function () {
                    updateReplaceMap(place, replaceNearbyList);
                }).catch(function () { /* map optional */ });
                selectedReplaceIdx = -1;
                updateReplaceConfirmButton();
                loadReplacePlacePreview(null);
                list.innerHTML = replaceNearbyList.map(function (item, idx) {
                    const name = escapeHtml(item.placeName || "장소");
                    const addr = escapeHtml(item.placeAddress || "");
                    const dist = item.distance != null ? Number(item.distance).toFixed(1) : "";
                    const rating = item.placeRating != null ? Number(item.placeRating).toFixed(1) : "";
                    const thumb = item.placeThumbnailUrl ? escapeHtml(item.placeThumbnailUrl) : "";
                    const thumbHtml = thumb ? "<img class=\"planner-replace-thumb\" src=\"" + thumb + "\" alt=\"\" />" : "<div class=\"planner-replace-thumb placeholder\"></div>";
                    const detailUrl = item.placeNo ? (ctx + "/place/detail?place_no=" + item.placeNo) : "";
                    const nameEl = detailUrl
                        ? "<span class=\"planner-replace-name-wrap\"><a href=\"" + detailUrl + "\" class=\"planner-replace-name\" target=\"_blank\" rel=\"noopener\">" + name + "</a></span>"
                        : "<strong class=\"planner-replace-name\">" + name + "</strong>";
                    return "<div class=\"planner-replace-item\" data-idx=\"" + idx + "\">" +
                        "<div class=\"planner-replace-card-inner\">" +
                        "<div class=\"planner-replace-thumb-wrap\">" + thumbHtml + "</div>" +
                        "<div class=\"planner-replace-info\">" +
                        nameEl +
                        (addr ? "<span class=\"planner-replace-addr\">" + addr + "</span>" : "") +
                        "<div class=\"planner-replace-meta\">" +
                        (dist ? "<span class=\"planner-replace-dist\">" + escapeHtml(dist) + " km</span>" : "") +
                        (rating ? "<span class=\"planner-replace-rating\">★ " + escapeHtml(rating) + "</span>" : "") +
                        "</div></div></div>" +
                        "<div class=\"planner-replace-card-expanded\"></div></div>";
                }).join("");
                qsAll(".planner-replace-item a.planner-replace-name", list).forEach(function (link) {
                    link.addEventListener("click", function (e) { e.stopPropagation(); });
                });
                qsAll(".planner-replace-item", list).forEach(function (el) {
                    var idx = parseInt(el.getAttribute("data-idx"), 10);
                    el.addEventListener("click", function () {
                        selectedReplaceIdx = idx;
                        qsAll(".planner-replace-item", list).forEach(function (x) { x.classList.remove("selected"); });
                        el.classList.add("selected");
                        setReplaceMapSelectedIdx(idx);
                        var item = replaceNearbyList[idx];
                        if (item && replaceMapInstance) {
                            var lat = item.placeLatitude != null ? parseFloat(item.placeLatitude) : NaN;
                            var lng = item.placeLongitude != null ? parseFloat(item.placeLongitude) : NaN;
                            var curPlace = places.find(function (p) { return String(p.id) === String(replacePlaceId); });
                            var curLat = curPlace && curPlace.placeLatitude != null ? parseFloat(curPlace.placeLatitude) : NaN;
                            var curLng = curPlace && curPlace.placeLongitude != null ? parseFloat(curPlace.placeLongitude) : NaN;
                            if (!isNaN(lat) && !isNaN(lng)) {
                                var bounds = new kakao.maps.LatLngBounds();
                                bounds.extend(new kakao.maps.LatLng(lat, lng));
                                if (!isNaN(curLat) && !isNaN(curLng)) bounds.extend(new kakao.maps.LatLng(curLat, curLng));
                                var sw = bounds.getSouthWest();
                                var ne = bounds.getNorthEast();
                                var midLat = !isNaN(curLat) ? (lat + curLat) / 2 : lat;
                                var midLng = !isNaN(curLng) ? (lng + curLng) / 2 : lng;
                                if (sw && ne) {
                                    var latSpan = Math.abs(ne.getLat() - sw.getLat());
                                    var lngSpan = Math.abs(ne.getLng() - sw.getLng());
                                    if (latSpan < 0.005 && lngSpan < 0.005) {
                                        replaceMapInstance.setCenter(new kakao.maps.LatLng(midLat, midLng));
                                        replaceMapInstance.setLevel(5);
                                    } else {
                                        replaceMapInstance.setBounds(bounds, 50, 50, 50, 50);
                                    }
                                } else {
                                    replaceMapInstance.setCenter(new kakao.maps.LatLng(midLat, midLng));
                                    replaceMapInstance.setLevel(5);
                                }
                            }
                        }
                        updateReplaceConfirmButton();
                        loadReplacePlacePreview(item ? item.placeNo : null);
                    });
                });
            })
            .catch(function () {
                list.innerHTML = "<p class=\"planner-replace-msg\">검색 중 오류가 발생했습니다.</p>";
            });
    }

    function applyReplacePlace(newPlace) {
        const place = places.find(function (p) { return String(p.id) === String(replacePlaceId); });
        if (!place) { closeReplaceModal(); return; }
        place.placeNo = newPlace.placeNo;
        place.placeName = newPlace.placeName;
        place.placeAddress = newPlace.placeAddress;
        place.placeLatitude = newPlace.placeLatitude;
        place.placeLongitude = newPlace.placeLongitude;
        closeReplaceModal();
        render();
        alert("변경되었습니다. 아래 저장 버튼을 눌러 반영해 주세요.");
    }

    function updateReplaceConfirmButton() {
        var btn = id("replaceConfirmBtn");
        if (btn) btn.disabled = selectedReplaceIdx < 0;
    }

    function formatReviewDate(ts) {
        if (ts == null) return "";
        var d = new Date(ts);
        if (isNaN(d.getTime())) return "";
        var now = new Date();
        var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        var then = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        var diffDays = Math.floor((today - then) / (24 * 60 * 60 * 1000));
        if (diffDays === 0) return "오늘";
        if (diffDays === 1) return "어제";
        if (diffDays < 7) return diffDays + "일 전";
        var y = d.getFullYear(), m = d.getMonth() + 1, day = d.getDate();
        return y + "." + m + "." + day;
    }

    function clearAllReplaceCardExpanded() {
        var list = id("replacePlaceList");
        if (!list) return;
        qsAll(".planner-replace-card-expanded", list).forEach(function (el) { el.innerHTML = ""; });
    }

    function loadReplacePlacePreview(placeNo) {
        var list = id("replacePlaceList");
        clearAllReplaceCardExpanded();
        if (!placeNo) return;
        var card = list && selectedReplaceIdx >= 0 ? list.querySelector(".planner-replace-item[data-idx=\"" + selectedReplaceIdx + "\"]") : null;
        var expanded = card ? card.querySelector(".planner-replace-card-expanded") : null;
        if (!expanded) return;
        expanded.innerHTML = "<span class=\"planner-replace-msg\">로딩 중...</span>";
        var requestedPlaceNo = placeNo;
        fetch(ctx + "/planner/place-preview?placeNo=" + placeNo, { credentials: "same-origin" })
            .then(function (res) { return res.ok ? res.json() : {}; })
            .then(function (data) {
                var current = selectedReplaceIdx >= 0 && replaceNearbyList[selectedReplaceIdx] ? replaceNearbyList[selectedReplaceIdx].placeNo : null;
                if (current !== requestedPlaceNo) return;
                var cardEl = list.querySelector(".planner-replace-item[data-idx=\"" + selectedReplaceIdx + "\"]");
                var exp = cardEl ? cardEl.querySelector(".planner-replace-card-expanded") : null;
                if (!exp) return;
                var detailLinkHtml = "<a href=\"" + ctx + "/place/detail?place_no=" + requestedPlaceNo + "\" class=\"planner-replace-detail-link\" target=\"_blank\" rel=\"noopener\" onclick=\"event.stopPropagation()\">상세 페이지 보기</a>";
                var urls = data.photoUrls || [];
                var photosHtml = urls.length === 0
                    ? "<p class=\"planner-replace-msg\">등록된 사진이 없습니다.</p>"
                    : urls.slice(0, 10).map(function (url) {
                        return "<img class=\"planner-replace-preview-photo\" src=\"" + escapeHtml(url) + "\" alt=\"\" />";
                    }).join("");
                var reviews = data.reviews || [];
                var reviewsHtml = reviews.length === 0
                    ? "<p class=\"planner-replace-msg\">최근 리뷰가 없습니다.</p>"
                    : "<h5>최근 리뷰</h5>" + reviews.map(function (r) {
                        var rating = r.rating != null ? "★ " + r.rating : "";
                        var by = escapeHtml(r.createdBy || "");
                        var dateStr = formatReviewDate(r.createdAt);
                        var meta = [rating, by, dateStr].filter(Boolean).join(" · ");
                        var content = escapeHtml((r.commentContent || "").slice(0, 120));
                        if ((r.commentContent || "").length > 120) content += "…";
                        return "<div class=\"planner-replace-review-item\"><span class=\"planner-replace-review-meta\">" + meta + "</span><p>" + content + "</p></div>";
                    }).join("");
                exp.innerHTML = "<div class=\"planner-replace-expanded-inner\">" + detailLinkHtml + "<div class=\"planner-replace-expanded-photos\">" + photosHtml + "</div><div class=\"planner-replace-expanded-reviews\">" + reviewsHtml + "</div></div>";
            })
            .catch(function () {
                if (selectedReplaceIdx >= 0 && replaceNearbyList[selectedReplaceIdx] && replaceNearbyList[selectedReplaceIdx].placeNo === requestedPlaceNo) {
                    var cardEl = list && list.querySelector(".planner-replace-item[data-idx=\"" + selectedReplaceIdx + "\"]");
                    var exp = cardEl ? cardEl.querySelector(".planner-replace-card-expanded") : null;
                    if (exp) exp.innerHTML = "<p class=\"planner-replace-msg\">불러올 수 없습니다.</p>";
                }
            });
    }

    function closeReplaceModal() {
        selectedReplaceIdx = -1;
        updateReplaceConfirmButton();
        loadReplacePlacePreview(null);
        replaceMarkers.forEach(function (item) {
            if (item && item.overlay && item.overlay.setMap) item.overlay.setMap(null);
        });
        replaceMarkers = [];
        if (replaceCurrentOverlay && replaceCurrentOverlay.setMap) replaceCurrentOverlay.setMap(null);
        replaceCurrentOverlay = null;
        const mapEl = id("replaceMap");
        if (mapEl) mapEl.classList.add("hidden");
        const modal = id("replaceModal");
        if (modal) modal.classList.add("hidden");
        replacePlaceId = null;
    }

    function setReplaceMapSelectedIdx(idx) {
        replaceMarkers.forEach(function (item, i) {
            if (!item || !item.content) return;
            item.content.className = i === idx ? "planner-pin-wrap planner-marker-selected" : "planner-pin-wrap planner-marker-candidate";
        });
    }

    function createPinSvg() {
        return "<svg class=\"planner-pin-svg\" viewBox=\"0 0 24 36\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" fill=\"currentColor\" stroke=\"currentColor\" stroke-width=\"0.8\" d=\"M12 0C5.373 0 0 5.373 0 12c0 9 12 24 12 24s12-15 12-24C24 5.373 18.627 0 12 0z M18 12A6 6 0 0 1 12 18A6 6 0 0 1 6 12A6 6 0 0 1 12 6A6 6 0 0 1 18 12z\"/></svg>";
    }

    function ensureReplaceMapReady() {
        if (replaceMapInstance) return Promise.resolve();
        return new Promise(function (resolve, reject) {
            if (!window.kakao || !window.kakao.maps) {
                reject(new Error("Kakao maps not loaded"));
                return;
            }
            window.kakao.maps.load(function () {
                const container = id("replaceMap");
                if (!container) { reject(new Error("replaceMap not found")); return; }
                try {
                    container.classList.remove("hidden");
                    replaceMapInstance = new kakao.maps.Map(container, {
                        center: new kakao.maps.LatLng(37.5665, 126.978),
                        level: 6
                    });
                    resolve();
                } catch (e) {
                    reject(e);
                }
            });
        });
    }

    function updateReplaceMap(currentPlace, nearbyList) {
        const mapEl = id("replaceMap");
        if (!mapEl || !replaceMapInstance) return;
        mapEl.classList.remove("hidden");
        replaceMarkers.forEach(function (item) {
            if (item && item.overlay && item.overlay.setMap) item.overlay.setMap(null);
        });
        replaceMarkers = [];
        if (replaceCurrentOverlay && replaceCurrentOverlay.setMap) replaceCurrentOverlay.setMap(null);
        var curLat = parseFloat(currentPlace.placeLatitude);
        var curLng = parseFloat(currentPlace.placeLongitude);
        if (!isNaN(curLat) && !isNaN(curLng)) {
            var currentContent = document.createElement("div");
            currentContent.className = "planner-pin-wrap planner-marker-current";
            currentContent.innerHTML = createPinSvg();
            replaceCurrentOverlay = new kakao.maps.CustomOverlay({
                position: new kakao.maps.LatLng(curLat, curLng),
                content: currentContent,
                yAnchor: 1
            });
            replaceCurrentOverlay.setMap(replaceMapInstance);
        }
        var bounds = new kakao.maps.LatLngBounds();
        if (!isNaN(curLat) && !isNaN(curLng)) bounds.extend(new kakao.maps.LatLng(curLat, curLng));
        nearbyList.forEach(function (item, idx) {
            var lat = item.placeLatitude != null ? parseFloat(item.placeLatitude) : NaN;
            var lng = item.placeLongitude != null ? parseFloat(item.placeLongitude) : NaN;
            if (isNaN(lat) || isNaN(lng)) return;
            var content = document.createElement("div");
            content.className = "planner-pin-wrap planner-marker-candidate";
            content.innerHTML = createPinSvg();
            var overlay = new kakao.maps.CustomOverlay({
                position: new kakao.maps.LatLng(lat, lng),
                content: content,
                yAnchor: 1
            });
            overlay.setMap(replaceMapInstance);
            replaceMarkers.push({ overlay: overlay, content: content });
            bounds.extend(new kakao.maps.LatLng(lat, lng));
        });
        if (bounds.getSouthWest() && bounds.getNorthEast()) {
            replaceMapInstance.setBounds(bounds, 40, 40, 40, 40);
        } else if (!isNaN(curLat) && !isNaN(curLng)) {
            replaceMapInstance.setCenter(new kakao.maps.LatLng(curLat, curLng));
            replaceMapInstance.setLevel(6);
        }
    }

    function openCompleteReviewModal() {
        const modal = id("completeReviewModal");
        const summaryEl = id("completeReviewRouteSummary");
        if (!modal || !summaryEl) return;
        if (places.length === 0) {
            alert("장소를 최소 1개 이상 추가한 뒤 여행 완료를 할 수 있어요.");
            return;
        }
        var steps = places.map(function (p, i) {
            return (i + 1) + ". " + escapeHtml(p.placeName || "장소");
        }).join(" → ");
        summaryEl.innerHTML = "<p class=\"planner-complete-route-text\">" + steps + "</p>";
        var titleInput = id("completeReviewPlanTitle");
        var headerTitle = id("planTitle");
        if (titleInput && headerTitle) titleInput.value = headerTitle.value || "";
        var pubCheck = id("planIsPublicComplete");
        var pubVal = id("planIsPublicValue");
        if (pubCheck && pubVal) {
            pubCheck.onchange = function () { pubVal.value = pubCheck.checked ? "Y" : "N"; };
        }
        modal.classList.remove("hidden");
    }

    function closeCompleteReviewModal() {
        const modal = id("completeReviewModal");
        if (modal) modal.classList.add("hidden");
    }

    function buildPayload() {
        const startStr = getPlanStartDate();
        return places.map(function (p) {
            return {
                placeNo: p.placeNo || null,
                placeName: p.placeName || "",
                placeAddress: p.placeAddress || "",
                placeLatitude: p.placeLatitude != null ? p.placeLatitude : null,
                placeLongitude: p.placeLongitude != null ? p.placeLongitude : null,
                date: p.date || startStr,
                time: p.time || "",
                endDate: p.endDate || "",
                endTime: p.endTime || "",
                memo: p.memo || ""
            };
        });
    }

    function openMapModal() {
        const modal = id("mapModal");
        if (!modal) return;
        modal.classList.remove("hidden");
        ensureMapReady().then(function () {
            if (id("placeSearch")) id("placeSearch").value = "";
            if (id("searchResults")) id("searchResults").innerHTML = "";
        }).catch(function () { alert("지도를 불러올 수 없습니다."); });
    }

    function closeMapModal() {
        const modal = id("mapModal");
        if (modal) modal.classList.add("hidden");
        selectedPlace = null;
        const res = id("searchResults");
        if (res) res.innerHTML = "";
    }

    function confirmPlace() {
        if (!selectedPlace) {
            alert("장소를 선택해 주세요.");
            return;
        }
        const startStr = getPlanStartDate();
        places.push({
            id: createPlaceId(),
            placeNo: selectedPlace.placeNo || null,
            placeName: selectedPlace.placeName || "",
            placeAddress: selectedPlace.placeAddress || "",
            placeLatitude: selectedPlace.placeLatitude,
            placeLongitude: selectedPlace.placeLongitude,
            date: startStr,
            time: "",
            endDate: "",
            endTime: "",
            memo: "",
            dayNumber: 1
        });
        render();
        closeMapModal();
    }

    function ensureMapReady() {
        if (mapReady && map && placeService) return Promise.resolve();
        return new Promise(function (resolve, reject) {
            if (window.kakao && window.kakao.maps && window.kakao.maps.services) {
                window.kakao.maps.load(function () {
                    try {
                        const container = id("map");
                        if (!container) throw new Error("map container not found");
                        map = new kakao.maps.Map(container, {
                            center: new kakao.maps.LatLng(37.5665, 126.978),
                            level: 5
                        });
                        marker = new kakao.maps.Marker();
                        placeService = new kakao.maps.services.Places();
                        mapReady = true;
                        resolve();
                    } catch (e) {
                        reject(e);
                    }
                });
            } else {
                reject(new Error("Kakao maps not loaded"));
            }
        });
    }

    function searchPlace() {
        const q = (id("placeSearch") && id("placeSearch").value) || "";
        if (!q.trim()) return;
        ensureMapReady().then(function () {
            placeService.keywordSearch(q.trim(), function (data, status) {
                const res = id("searchResults");
                if (!res) return;
                if (status !== kakao.maps.services.Status.OK || !data || data.length === 0) {
                    res.innerHTML = "<div class=\"planner-search-item\">검색 결과가 없습니다.</div>";
                    return;
                }
                res.innerHTML = data.map(function (item) {
                    const name = escapeHtml(item.place_name || "");
                    const addr = escapeHtml(item.road_address_name || item.address_name || "");
                    const y = item.y || "";
                    const x = item.x || "";
                    return "<div class=\"planner-search-item\" data-name=\"" + name + "\" data-address=\"" + addr + "\" data-lat=\"" + y + "\" data-lng=\"" + x + "\">" +
                        "<strong>" + name + "</strong><br><span class=\"planner-search-addr\">" + addr + "</span></div>";
                }).join("");
                qsAll(".planner-search-item", res).forEach(function (el) {
                    el.addEventListener("click", function () {
                        qsAll(".planner-search-item", res).forEach(function (x) { x.classList.remove("selected"); });
                        el.classList.add("selected");
                        const lat = parseFloat(el.getAttribute("data-lat"));
                        const lng = parseFloat(el.getAttribute("data-lng"));
                        if (map && !isNaN(lat) && !isNaN(lng)) {
                            map.setCenter(new kakao.maps.LatLng(lat, lng));
                            marker.setPosition(new kakao.maps.LatLng(lat, lng));
                            marker.setMap(map);
                        }
                        selectedPlace = {
                            placeNo: null,
                            placeName: el.getAttribute("data-name") || "",
                            placeAddress: el.getAttribute("data-address") || "",
                            placeLatitude: lat,
                            placeLongitude: lng
                        };
                    });
                });
                if (data.length > 0 && map) {
                    const bounds = new kakao.maps.LatLngBounds();
                    data.forEach(function (item) {
                        const y = parseFloat(item.y);
                        const x = parseFloat(item.x);
                        if (!isNaN(y) && !isNaN(x)) bounds.extend(new kakao.maps.LatLng(y, x));
                    });
                    map.setBounds(bounds);
                }
            });
        });
    }

    function escapeHtml(s) {
        if (s == null) return "";
        return String(s)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;");
    }

    function recalcDayNumbers() {
        const startStr = getPlanStartDate();
        if (!startStr) return;
        const startDate = new Date(startStr);
        startDate.setHours(0, 0, 0, 0);
        places.forEach(function (p) {
            const d = (p.date || startStr).toString();
            if (!d) {
                p.dayNumber = 1;
                return;
            }
            const visitDate = new Date(d);
            visitDate.setHours(0, 0, 0, 0);
            const diff = Math.floor((visitDate - startDate) / (24 * 60 * 60 * 1000));
            p.dayNumber = Math.max(1, diff + 1);
        });
    }

    document.addEventListener("DOMContentLoaded", function () {
        loadInitial();
        recalcDayNumbers();
        render();

        if (id("planStartDate")) id("planStartDate").addEventListener("change", function () { recalcDayNumbers(); render(); });
        if (id("planEndDate")) id("planEndDate").addEventListener("change", function () { recalcDayNumbers(); render(); });
        if (id("btnAddPlace")) id("btnAddPlace").addEventListener("click", openMapModal);
        if (id("btnCompleteReview")) id("btnCompleteReview").addEventListener("click", openCompleteReviewModal);
        if (id("closeCompleteReviewModal")) id("closeCompleteReviewModal").addEventListener("click", closeCompleteReviewModal);
        if (id("cancelCompleteReview")) id("cancelCompleteReview").addEventListener("click", closeCompleteReviewModal);
        if (id("closeMapModal")) id("closeMapModal").addEventListener("click", closeMapModal);
        if (id("closeReplaceModal")) id("closeReplaceModal").addEventListener("click", closeReplaceModal);
        if (id("replaceSearchBtn")) id("replaceSearchBtn").addEventListener("click", fetchReplacePlaces);
        if (id("replaceConfirmBtn")) id("replaceConfirmBtn").addEventListener("click", function () {
            if (selectedReplaceIdx < 0) return;
            var item = replaceNearbyList[selectedReplaceIdx];
            if (!item) return;
            applyReplacePlace({
                placeNo: item.placeNo || null,
                placeName: item.placeName || "",
                placeAddress: item.placeAddress || "",
                placeLatitude: item.placeLatitude != null ? item.placeLatitude : null,
                placeLongitude: item.placeLongitude != null ? item.placeLongitude : null
            });
        });
        if (id("searchBtn")) id("searchBtn").addEventListener("click", searchPlace);
        if (id("confirmPlace")) id("confirmPlace").addEventListener("click", confirmPlace);
        if (id("placeSearch")) id("placeSearch").addEventListener("keypress", function (e) {
            if (e.key === "Enter") { e.preventDefault(); searchPlace(); }
        });

        const form = id("plannerEditForm");
        if (form) {
            form.addEventListener("submit", function (e) {
                e.preventDefault();
                if (places.length === 0) {
                    alert("장소를 최소 1개 이상 추가해 주세요.");
                    return;
                }
                recalcDayNumbers();
                const jsonInput = id("planDetailsJson");
                if (jsonInput) jsonInput.value = JSON.stringify(buildPayload());
                form.submit();
            });
        }
    });
})();
