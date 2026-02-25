(function () {
    "use strict";
    const ctx = typeof window.appContextPath !== "undefined" ? window.appContextPath : "";
    let places = [];
    let selectedPlace = null;
    let map = null;
    let marker = null;
    let placeService = null;
    let mapReady = false;
    let mapSearchKakaoList = [];
    let mapSearchEnriched = {};

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

    function isDirectPath() {
        return directPanel && directPanel.classList.contains("planner-wizard-active");
    }

    function init() {
        const form = id("plannerNewForm");
        const btnSearchRoutes = id("btnSearchRoutes");
        const btnAddPlace = id("btnAddPlace");

        step1Panel = id("step1Panel");
        step2Panel = id("step2Panel");
        step3Panel = id("step3Panel");
        directPanel = id("directPanel");

        if (id("choiceRoute")) id("choiceRoute").addEventListener("click", function () { showPanel(step2Panel); });
        if (id("choiceDirect")) id("choiceDirect").addEventListener("click", function () { showPanel(directPanel); updateSaveState(); });
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
                if (isDirectPath() && places.length === 0) {
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
        var btnSave = id("btnSaveNewDirect");
        if (!btnSave) return;
        var canSave = places.length > 0;
        btnSave.disabled = !canSave;
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

    var routeListAll = [];
    var routeListPage = 1;
    var routeListPageSize = 6;

    function renderRouteListPage(area, routes, page) {
        var total = routes.length;
        var totalPages = Math.max(1, Math.ceil(total / routeListPageSize));
        var p = Math.max(1, Math.min(page, totalPages));
        var start = (p - 1) * routeListPageSize;
        var pageRoutes = routes.slice(start, start + routeListPageSize);

        var listHtml = pageRoutes.map(function (route) {
            var matchLabel = route.matchScore != null ? " <span class=\"planner-route-match\">" + route.matchScore + "% 적합</span>" : "";
            var stepsHtml = "";
            var stepDetails = route.stepDetails;
            if (Array.isArray(stepDetails) && stepDetails.length > 0) {
                var parts = stepDetails.slice(0, 8).map(function (s) {
                    var name = escapeHtml((s && s.placeName) ? s.placeName : "");
                    var img = (s && s.placeThumbnailUrl) ? s.placeThumbnailUrl : "";
                    if (img) {
                        return "<span class=\"planner-route-step-thumb\"><img src=\"" + escapeHtml(img) + "\" alt=\"\" /><span class=\"planner-route-step-name\">" + name + "</span></span>";
                    }
                    return "<span class=\"planner-route-step-thumb planner-route-step-noimg\"><span class=\"planner-route-step-name\">" + name + "</span></span>";
                });
                if (stepDetails.length > 8) parts.push("<span class=\"planner-route-step-more\">…</span>");
                stepsHtml = "<div class=\"planner-route-steps planner-route-steps-thumbs\">" + parts.join("") + "</div>";
            } else {
                var steps = route.steps;
                if (Array.isArray(steps) && steps.length > 0) {
                    var stepsText = steps.slice(0, 5).map(function (s) { return escapeHtml(s || ""); }).join(" → ");
                    if (steps.length > 5) stepsText += " …";
                    stepsHtml = "<div class=\"planner-route-steps\">" + stepsText + "</div>";
                }
            }
            return "<div class=\"planner-route-item\">" +
                "<div class=\"planner-route-item-head\">" +
                "<strong>" + escapeHtml(route.title || "") + "</strong>" + matchLabel +
                "</div>" + stepsHtml +
                "<button type=\"button\" class=\"planner-btn-use-route\" data-route-id=\"" + (route.id || "") + "\">이 루트로 만들기</button>" +
                "</div>";
        }).join("");

        var listEl = area.querySelector(".planner-route-list");
        if (listEl) listEl.innerHTML = listHtml;

        var navEl = area.querySelector(".planner-route-pagination");
        if (navEl) {
            var prevDisabled = p <= 1 ? " disabled" : "";
            var nextDisabled = p >= totalPages ? " disabled" : "";
            navEl.innerHTML = "<button type=\"button\" class=\"planner-route-page-btn\" data-page=\"prev\"" + prevDisabled + ">이전</button>" +
                "<span class=\"planner-route-page-info\">" + p + " / " + totalPages + "</span>" +
                "<button type=\"button\" class=\"planner-route-page-btn\" data-page=\"next\"" + nextDisabled + ">다음</button>";
            navEl.querySelectorAll(".planner-route-page-btn").forEach(function (btn) {
                btn.addEventListener("click", function () {
                    if (btn.disabled) return;
                    var toPage = btn.getAttribute("data-page") === "next" ? p + 1 : p - 1;
                    routeListPage = toPage;
                    renderRouteListPage(area, routeListAll, toPage);
                });
            });
        }

        qsAll(".planner-btn-use-route", area).forEach(function (btn) {
            btn.addEventListener("click", function () {
                var routeId = btn.getAttribute("data-route-id");
                if (!routeId) return;
                useRoute(routeId);
            });
        });
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
                routeListAll = routes;
                routeListPage = 1;
                area.innerHTML = "<p class=\"planner-route-result-intro\">선택한 장소 태그에 맞는 루트를 우선 보여드려요. 아래 루트를 선택하면 내 일정으로 저장됩니다.</p>" +
                    "<div class=\"planner-route-list\"></div>" +
                    "<div class=\"planner-route-pagination\"></div>";
                renderRouteListPage(area, routes, 1);
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
        mapSearchKakaoList = [];
        mapSearchEnriched = {};
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

    function clearAllSearchCardExpanded() {
        var container = id("searchResults");
        if (!container) return;
        qsAll(".planner-replace-card-expanded", container).forEach(function (el) { el.innerHTML = ""; });
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

    function loadSearchPlacePreview(placeNo, cardEl) {
        if (!cardEl) return;
        var expanded = cardEl.querySelector(".planner-replace-card-expanded");
        if (!expanded) return;
        if (!placeNo) {
            expanded.innerHTML = "<p class=\"planner-replace-msg\">등록된 상세 정보가 없습니다.</p>";
            return;
        }
        expanded.innerHTML = "<span class=\"planner-replace-msg\">로딩 중...</span>";
        var requestedPlaceNo = placeNo;
        fetch(ctx + "/planner/place-preview?placeNo=" + placeNo, { credentials: "same-origin" })
            .then(function (res) { return res.ok ? res.json() : {}; })
            .then(function (data) {
                var exp = cardEl.querySelector(".planner-replace-card-expanded");
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
                var exp = cardEl.querySelector(".planner-replace-card-expanded");
                if (exp) exp.innerHTML = "<p class=\"planner-replace-msg\">불러올 수 없습니다.</p>";
            });
    }

    function updateSearchCardContent(cardEl, place) {
        if (!cardEl || !place) return;
        var inner = cardEl.querySelector(".planner-replace-card-inner");
        if (!inner) return;
        var name = escapeHtml(place.placeName || "");
        var addr = escapeHtml(place.placeAddress || "");
        var thumb = place.placeThumbnailUrl ? escapeHtml(place.placeThumbnailUrl) : "";
        var thumbHtml = thumb ? "<img class=\"planner-replace-thumb\" src=\"" + thumb + "\" alt=\"\" />" : "<div class=\"planner-replace-thumb placeholder\"></div>";
        var detailUrl = place.placeNo ? (ctx + "/place/detail?place_no=" + place.placeNo) : "";
        var nameEl = detailUrl
            ? "<span class=\"planner-replace-name-wrap\"><a href=\"" + detailUrl + "\" class=\"planner-replace-name\" target=\"_blank\" rel=\"noopener\">" + name + "</a></span>"
            : "<strong class=\"planner-replace-name\">" + name + "</strong>";
        var rating = place.placeRating != null ? Number(place.placeRating).toFixed(1) : "";
        inner.innerHTML = "<div class=\"planner-replace-thumb-wrap\">" + thumbHtml + "</div>" +
            "<div class=\"planner-replace-info\">" +
            nameEl +
            (addr ? "<span class=\"planner-replace-addr\">" + addr + "</span>" : "") +
            "<div class=\"planner-replace-meta\">" +
            (rating ? "<span class=\"planner-replace-rating\">★ " + escapeHtml(rating) + "</span>" : "") +
            "</div></div>";
        qsAll("a.planner-replace-name", inner).forEach(function (link) {
            link.addEventListener("click", function (e) { e.stopPropagation(); });
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
                    mapSearchKakaoList = [];
                    return;
                }
                mapSearchKakaoList = data;
                mapSearchEnriched = {};
                res.innerHTML = data.map(function (item, idx) {
                    const name = escapeHtml(item.place_name || "");
                    const addr = escapeHtml(item.road_address_name || item.address_name || "");
                    const y = item.y || "";
                    const x = item.x || "";
                    return "<div class=\"planner-replace-item planner-search-card\" data-idx=\"" + idx + "\" data-name=\"" + name + "\" data-address=\"" + addr + "\" data-lat=\"" + y + "\" data-lng=\"" + x + "\">" +
                        "<div class=\"planner-replace-card-inner\">" +
                        "<div class=\"planner-replace-thumb-wrap\"><div class=\"planner-replace-thumb placeholder\"></div></div>" +
                        "<div class=\"planner-replace-info\">" +
                        "<strong class=\"planner-replace-name\">" + name + "</strong>" +
                        (addr ? "<span class=\"planner-replace-addr\">" + addr + "</span>" : "") +
                        "<div class=\"planner-replace-meta\"></div></div></div>" +
                        "<div class=\"planner-replace-card-expanded\"></div></div>";
                }).join("");
                qsAll(".planner-search-card", res).forEach(function (el) {
                    el.addEventListener("click", function () {
                        qsAll(".planner-search-card", res).forEach(function (x) { x.classList.remove("selected"); });
                        el.classList.add("selected");
                        var idx = parseInt(el.getAttribute("data-idx"), 10);
                        var lat = parseFloat(el.getAttribute("data-lat"));
                        var lng = parseFloat(el.getAttribute("data-lng"));
                        var name = el.getAttribute("data-name") || "";
                        var address = el.getAttribute("data-address") || "";
                        if (map && !isNaN(lat) && !isNaN(lng)) {
                            map.setCenter(new kakao.maps.LatLng(lat, lng));
                            marker.setPosition(new kakao.maps.LatLng(lat, lng));
                            marker.setMap(map);
                        }
                        clearAllSearchCardExpanded();
                        var enriched = mapSearchEnriched[idx];
                        if (enriched != null) {
                            selectedPlace = {
                                placeNo: enriched.placeNo || null,
                                placeName: enriched.placeName || "",
                                placeAddress: enriched.placeAddress || "",
                                placeLatitude: lat,
                                placeLongitude: lng
                            };
                            updateSearchCardContent(el, enriched);
                            loadSearchPlacePreview(enriched.placeNo || null, el);
                        } else {
                            var url = ctx + "/planner/nearby-places?lat=" + encodeURIComponent(lat) + "&lng=" + encodeURIComponent(lng) + "&radiusKm=1";
                            fetch(url, { credentials: "same-origin" })
                                .then(function (r) { return r.ok ? r.json() : []; })
                                .then(function (arr) {
                                    var list = Array.isArray(arr) ? arr : [];
                                    var place = list.length > 0 ? list[0] : null;
                                    mapSearchEnriched[idx] = place;
                                    if (place) {
                                        selectedPlace = {
                                            placeNo: place.placeNo || null,
                                            placeName: place.placeName || "",
                                            placeAddress: place.placeAddress || "",
                                            placeLatitude: lat,
                                            placeLongitude: lng
                                        };
                                        updateSearchCardContent(el, place);
                                        loadSearchPlacePreview(place.placeNo || null, el);
                                    } else {
                                        selectedPlace = {
                                            placeNo: null,
                                            placeName: name,
                                            placeAddress: address,
                                            placeLatitude: lat,
                                            placeLongitude: lng
                                        };
                                        loadSearchPlacePreview(null, el);
                                    }
                                })
                                .catch(function () {
                                    selectedPlace = { placeNo: null, placeName: name, placeAddress: address, placeLatitude: lat, placeLongitude: lng };
                                    loadSearchPlacePreview(null, el);
                                });
                        }
                    });
                });
                data.forEach(function (item, idx) {
                    var lat = parseFloat(item.y);
                    var lng = parseFloat(item.x);
                    if (isNaN(lat) || isNaN(lng)) return;
                    var url = ctx + "/planner/nearby-places?lat=" + encodeURIComponent(lat) + "&lng=" + encodeURIComponent(lng) + "&radiusKm=1";
                    fetch(url, { credentials: "same-origin" })
                        .then(function (r) { return r.ok ? r.json() : []; })
                        .then(function (arr) {
                            var place = (Array.isArray(arr) && arr.length > 0) ? arr[0] : null;
                            mapSearchEnriched[idx] = place;
                            var cardEl = res.querySelector(".planner-search-card[data-idx=\"" + idx + "\"]");
                            if (cardEl && place) updateSearchCardContent(cardEl, place);
                        })
                        .catch(function () {});
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

    document.addEventListener("DOMContentLoaded", function () {
        init();
        renderPlaceList();
    });
})();
