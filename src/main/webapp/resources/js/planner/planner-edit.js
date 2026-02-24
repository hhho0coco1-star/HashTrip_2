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
            const emptyHint = list.length === 0 ? "<p class=\"planner-day-empty-hint\">장소를 여기로 드래그하세요</p>" : "";
            return "<div class=\"planner-day-group planner-day-dropzone\" data-day=\"" + dayNum + "\" data-date=\"" + (dayDate || "") + "\">" +
                "<h3 class=\"planner-day-title\">" + dayNum + "일차</h3>" +
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
        list.innerHTML = "<p>근처 여행지 검색은 준비 중입니다. 장소 추가로 새 장소를 넣은 뒤 순서를 바꿔 보세요.</p>";
        modal.classList.remove("hidden");
    }

    function closeReplaceModal() {
        const modal = id("replaceModal");
        if (modal) modal.classList.add("hidden");
        replacePlaceId = null;
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
