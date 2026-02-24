(function () {
    "use strict";
    const ctx = typeof window.appContextPath !== "undefined" ? window.appContextPath : "";
    let places = [];
    let selectedPlace = null;
    let map = null;
    let marker = null;
    let placeService = null;
    let mapReady = false;

    function id(s) { return document.getElementById(s); }
    function qs(s, r) { return (r || document).querySelector(s); }
    function qsAll(s, r) { return Array.from((r || document).querySelectorAll(s)); }

    var step1Panel = null;
    var step2Panel = null;
    var step3Panel = null;
    var directPanel = null;

    function showPanel(panel) {
        if (step1Panel) step1Panel.classList.add("hidden");
        if (step2Panel) step2Panel.classList.add("hidden");
        if (step3Panel) step3Panel.classList.add("hidden");
        if (directPanel) directPanel.classList.add("hidden");
        if (panel) {
            panel.classList.remove("hidden");
            panel.classList.add("planner-wizard-active");
        }
    }

    function init() {
        const form = id("plannerNewForm");
        const modeRoute = document.querySelector('input[name="createMode"][value="route"]');
        const modeDirect = document.querySelector('input[name="createMode"][value="direct"]');
        const btnSearchRoutes = id("btnSearchRoutes");
        const btnAddPlace = id("btnAddPlace");
        const btnSave = id("btnSaveNew");

        step1Panel = id("step1Panel");
        step2Panel = id("step2Panel");
        step3Panel = id("step3Panel");
        directPanel = id("directPanel");

        if (id("btnStep1Next")) id("btnStep1Next").addEventListener("click", function () {
            if (modeDirect && modeDirect.checked) {
                showPanel(directPanel);
                updateSaveState();
            } else {
                showPanel(step2Panel);
            }
        });
        if (id("btnStep2Prev")) id("btnStep2Prev").addEventListener("click", function () { showPanel(step1Panel); });
        if (id("btnStep2Next")) id("btnStep2Next").addEventListener("click", function () { showPanel(step3Panel); });
        if (id("btnStep3Prev")) id("btnStep3Prev").addEventListener("click", function () { showPanel(step2Panel); });
        if (id("btnDirectPrev")) id("btnDirectPrev").addEventListener("click", function () { showPanel(step1Panel); updateSaveState(); });

        if (btnSearchRoutes) btnSearchRoutes.addEventListener("click", searchAndShowRoutes);
        if (btnAddPlace) btnAddPlace.addEventListener("click", openMapModal);
        if (id("closeMapModal")) id("closeMapModal").addEventListener("click", closeMapModal);
        if (id("searchBtn")) id("searchBtn").addEventListener("click", searchPlace);
        if (id("confirmPlace")) id("confirmPlace").addEventListener("click", confirmPlace);
        if (id("placeSearch")) id("placeSearch").addEventListener("keypress", function (e) {
            if (e.key === "Enter") { e.preventDefault(); searchPlace(); }
        });

        if (form) {
            form.addEventListener("submit", function (e) {
                e.preventDefault();
                if (modeDirect && modeDirect.checked && places.length === 0) {
                    alert("장소를 최소 1개 이상 추가해 주세요.");
                    return;
                }
                var startInputEl = id("planStartDate");
                var endInputEl = id("planEndDate");
                if (startInputEl && endInputEl && (!startInputEl.value || !endInputEl.value)) {
                    var today = new Date();
                    var tomorrow = new Date(today);
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    startInputEl.value = today.toISOString().slice(0, 10);
                    endInputEl.value = tomorrow.toISOString().slice(0, 10);
                }
                var jsonInput = id("planDetailsJson");
                if (jsonInput) jsonInput.value = JSON.stringify(placesToPayload());
                form.submit();
            });
        }
        updateSaveState();
    }

    function updateSaveState() {
        var btnSave = id("btnSaveNew");
        var modeDirect = document.querySelector('input[name="createMode"][value="direct"]');
        var directPanelEl = id("directPanel");
        if (!btnSave) return;
        var isDirect = modeDirect && modeDirect.checked;
        var canSave = isDirect && places.length > 0;
        btnSave.disabled = !canSave;
        if (directPanelEl && directPanelEl.classList.contains("planner-wizard-active")) {
            btnSave.classList.toggle("hidden", !canSave);
        } else {
            btnSave.classList.add("hidden");
        }
    }

    function getDefaultStartDate() {
        var el = id("planStartDate");
        return (el && el.value) || new Date().toISOString().slice(0, 10);
    }

    function placesToPayload() {
        var start = getDefaultStartDate();
        return places.map(function (p) {
            return {
                placeNo: p.placeNo || null,
                placeName: p.placeName || "",
                placeAddress: p.placeAddress || "",
                placeLatitude: p.placeLatitude != null ? p.placeLatitude : null,
                placeLongitude: p.placeLongitude != null ? p.placeLongitude : null,
                date: p.date || start,
                time: p.time || "",
                endDate: p.endDate || "",
                endTime: p.endTime || "",
                memo: p.memo || ""
            };
        });
    }

    function confirmPlace() {
        if (!selectedPlace) {
            alert("장소를 선택해 주세요.");
            return;
        }
        var start = getDefaultStartDate();
        places.push({
            placeNo: selectedPlace.placeNo || null,
            placeName: selectedPlace.placeName || "",
            placeAddress: selectedPlace.placeAddress || "",
            placeLatitude: selectedPlace.placeLatitude,
            placeLongitude: selectedPlace.placeLongitude,
            date: start,
            time: "",
            endDate: "",
            endTime: "",
            memo: ""
        });
        renderPlaceList();
        closeMapModal();
        updateSaveState();
    }

    function renderPlaceList() {
        const list = id("placeList");
        if (!list) return;
        list.innerHTML = places.map(function (p, i) {
            const name = escapeHtml(p.placeName || "장소");
            return "<div class=\"planner-place-card\" data-index=\"" + i + "\">" +
                "<span class=\"planner-place-name\">" + name + "</span>" +
                "<button type=\"button\" class=\"planner-place-remove\" data-index=\"" + i + "\">삭제</button>" +
                "</div>";
        }).join("");
        qsAll(".planner-place-remove", list).forEach(function (btn) {
            btn.addEventListener("click", function () {
                var idx = parseInt(btn.getAttribute("data-index"), 10);
                places.splice(idx, 1);
                renderPlaceList();
                updateSaveState();
            });
        });
        updateSaveState();
    }

    function getSelectedPlaceTagNames() {
        const checked = qsAll('input[name="placeTag"]:checked');
        return checked.map(function (el) {
            var name = (el.getAttribute("data-name") || el.value || "").trim();
            return name.toLowerCase();
        }).filter(Boolean);
    }

    function routeMatchesPlaceTags(route, selectedTagNames) {
        if (!selectedTagNames || selectedTagNames.length === 0) return false;
        var tags = route.tags;
        if (tags && typeof tags === "object") {
            for (var key in tags) {
                if (tags.hasOwnProperty(key)) {
                    var val = (tags[key] || "").toLowerCase().replace(/^#/, "");
                    for (var i = 0; i < selectedTagNames.length; i++) {
                        if (val.indexOf(selectedTagNames[i]) !== -1 || selectedTagNames[i].indexOf(val) !== -1) return true;
                    }
                }
            }
        }
        var steps = route.steps;
        if (Array.isArray(steps)) {
            for (var j = 0; j < steps.length; j++) {
                var step = (steps[j] || "").toLowerCase();
                for (var k = 0; k < selectedTagNames.length; k++) {
                    if (step.indexOf(selectedTagNames[k]) !== -1) return true;
                }
            }
        }
        return false;
    }

    function searchAndShowRoutes() {
        var url = ctx + "/routes/filter?category=";
        var area = id("routeResultArea");
        if (!area) return;
        area.classList.remove("hidden");
        area.innerHTML = "<p>로딩 중...</p>";
        fetch(url)
            .then(function (r) { return r.json(); })
            .then(function (routes) {
                if (!routes || routes.length === 0) {
                    area.innerHTML = "<p>추천 루트가 없습니다. 직접 장소를 추가해 보세요.</p>";
                    return;
                }
                var selectedTagNames = getSelectedPlaceTagNames();
                routes = routes.slice();
                routes.sort(function (a, b) {
                    var aMatch = routeMatchesPlaceTags(a, selectedTagNames);
                    var bMatch = routeMatchesPlaceTags(b, selectedTagNames);
                    if (aMatch && !bMatch) return -1;
                    if (!aMatch && bMatch) return 1;
                    var scoreA = a.matchScore != null ? a.matchScore : 0;
                    var scoreB = b.matchScore != null ? b.matchScore : 0;
                    return scoreB - scoreA;
                });
                area.innerHTML = "<p class=\"planner-route-result-intro\">선택한 장소 태그에 맞는 루트를 우선 보여드려요. 아래 루트를 선택하면 내 일정으로 저장됩니다.</p>" +
                    routes.slice(0, 15).map(function (route) {
                        var matchLabel = route.matchScore != null ? " <span class=\"planner-route-match\">" + route.matchScore + "% 적합</span>" : "";
                        var steps = route.steps;
                        var stepsHtml = "";
                        if (Array.isArray(steps) && steps.length > 0) {
                            var stepsText = steps.slice(0, 5).map(function (s) { return escapeHtml(s || ""); }).join(" → ");
                            if (steps.length > 5) stepsText += " …";
                            stepsHtml = "<div class=\"planner-route-steps\">" + stepsText + "</div>";
                        }
                        return "<div class=\"planner-route-item\">" +
                            "<div class=\"planner-route-item-head\">" +
                            "<strong>" + escapeHtml(route.title || "") + "</strong>" + matchLabel +
                            "</div>" + stepsHtml +
                            "<button type=\"button\" class=\"planner-btn-use-route\" data-route-id=\"" + (route.id || "") + "\">이 루트로 만들기</button>" +
                            "</div>";
                    }).join("");
                qsAll(".planner-btn-use-route", area).forEach(function (btn) {
                    btn.addEventListener("click", function () {
                        var routeId = btn.getAttribute("data-route-id");
                        if (!routeId) return;
                        useRoute(routeId);
                    });
                });
            })
            .catch(function () {
                area.innerHTML = "<p>불러오기에 실패했습니다.</p>";
            });
    }

    function useRoute(routeId) {
        const csrfParam = (document.querySelector("meta[name='_csrf_parameter']") || {}).getAttribute("content") || "_csrf";
        const csrfToken = (document.querySelector("meta[name='_csrf']") || {}).getAttribute("content") || "";
        const headers = { "Content-Type": "application/x-www-form-urlencoded" };
        if (csrfToken) headers["X-CSRF-TOKEN"] = csrfToken;
        const body = "routeId=" + encodeURIComponent(routeId) + "&" + csrfParam + "=" + encodeURIComponent(csrfToken);
        fetch(ctx + "/routes/save", { method: "POST", headers: headers, body: body })
            .then(function (r) { return r.json().then(function (data) { return { ok: r.ok, data: data }; }); })
            .then(function (result) {
                if (result.ok && result.data && result.data.redirectUrl) {
                    var url = result.data.redirectUrl;
                    if (url.indexOf("/plan/") === 0) url = "/planner" + url.slice(5);
                    window.location.href = url.indexOf("/") === 0 ? ctx + url : url;
                } else if (result.data && result.data.loginRequired) {
                    window.location.href = ctx + (result.data.redirectUrl || "/auth/login");
                } else {
                    alert(result.data && result.data.message ? result.data.message : "저장에 실패했습니다.");
                }
            })
            .catch(function () { alert("저장 요청에 실패했습니다."); });
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

    function updateSaveState() {
        const btnSave = id("btnSaveNew");
        const startInput = id("planStartDate");
        const endInput = id("planEndDate");
        const modeDirect = document.querySelector('input[name="createMode"][value="direct"]');
        if (!btnSave) return;
        const hasDates = startInput && endInput && startInput.value && endInput.value;
        const isDirect = modeDirect && modeDirect.checked;
        btnSave.disabled = !(isDirect && hasDates && places.length > 0);
    }

    document.addEventListener("DOMContentLoaded", function () {
        init();
        renderPlaceList();
    });
})();
