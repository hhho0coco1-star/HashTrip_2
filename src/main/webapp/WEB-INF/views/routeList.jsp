<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>#HiFive — 추천 여행 루트</title>
    <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;600;700;800&family=Gmarket+Sans:wght@300;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/routes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/fragments/main-layout.css">
</head>

<body>

<jsp:include page="/WEB-INF/views/fragments/mainPage-Header.jsp" />

<div class="page-container">
    <div class="routes-wrap">

        <%-- ✅ 내 태그 요약 헤더 --%>
        <div class="personal-hero" id="personal-hero">
            <div class="personal-badge">
                <span class="personal-badge-icon">🛡️</span>
                Personalized Curation
            </div>
            <div class="personal-row">
                <div class="personal-main">
                    <div class="personal-title">
                        <span class="personal-name"><c:out value="${not empty personalUserName ? personalUserName : (not empty headerDisplayName ? headerDisplayName : (not empty userName ? userName : '여행자'))}"/></span>의
                        <span class="personal-strong">태그 큐레이션</span>
                    </div>
                    <div class="personal-desc">
                        <c:choose>
                            <c:when test="${empty personalUserName}">
                                홈에서 성향 분석 테스트를 먼저 진행해 주세요
                            </c:when>
                            <c:when test="${not empty myTopTags}">
                                취향을 분석하여 최적의 여행 루트를 설계하고 있어요
                            </c:when>
                            <c:otherwise>
                                아직 등록된 취향 태그가 없어요. 홈에서 성향 분석 테스트를 진행해 주세요
                            </c:otherwise>
                        </c:choose>
                        <span class="dot-loader" aria-hidden="true"><i></i><i></i><i></i></span>
                    </div>
                </div>

                <div class="personal-stat-card">
                    <div class="personal-stat-icon">🏷️</div>
                    <div class="personal-stat-body">
                        <div class="personal-stat-label">Total Tags</div>
                        <div class="personal-stat-value">
                            <b><c:out value="${not empty myTagCount ? myTagCount : 0}"/></b><span>개</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="personal-meta-block">
                <div class="personal-meta-title">Selected Moods</div>
                <div class="personal-meta" id="personal-meta">
                    <c:choose>
                        <c:when test="${not empty myTopTags}">
                            <c:forEach var="tagName" items="${myTopTags}">
                                <span class="meta-pill meta-tag">✨ #<c:out value="${tagName}"/></span>
                            </c:forEach>

                            <c:forEach var="tagName" items="${myAllTags}" begin="${fn:length(myTopTags)}">
                                <span class="meta-pill meta-tag meta-extra-tag hidden">✨ #<c:out value="${tagName}"/></span>
                            </c:forEach>

                            <c:if test="${fn:length(myAllTags) > fn:length(myTopTags)}">
                                <button type="button"
                                        class="meta-pill meta-link meta-link-btn"
                                        id="personal-meta-toggle"
                                        aria-expanded="false"
                                        onclick="togglePersonalTags()">
                                    전체보기 <span class="meta-arrow">›</span>
                                </button>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <span class="meta-pill meta-empty">등록된 태그 없음</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="routes-header">
            <div class="section-badge">RECOMMENDED ROUTES</div>
            <div class="routes-header-row">
                <h2 class="section-title">🗺️ 추천 여행 루트</h2>
                <button type="button"
                        class="btn-cta-outline btn-share"
                        id="btn-create-plan"
                        onclick="location.href='${pageContext.request.contextPath}/planner/new'">+ 내 일정 작성</button>
            </div>
            <p class="section-subtitle">취향이 맞는 여행자들의 루트를 발견해보세요</p>
        </div>

        <div class="preference-filter-panel" id="preference-filter-panel">
            <div class="preference-filter-head">
                <div class="preference-filter-title">취향 탐색 필터</div>
                <div class="preference-actions preference-actions-head">
                    <button type="button" class="pref-action-btn pref-apply" onclick="applyPreferenceFilter()">필터 적용</button>
                    <button type="button" class="pref-action-btn pref-reset" onclick="resetPreferenceFilter()">초기화</button>
                </div>
            </div>

            <div class="preference-top" id="preference-top">
                <c:forEach var="pref" items="${preferenceCategories}">
                    <button type="button"
                            class="pref-chip pref-top-chip"
                            data-pref-category="${pref.categoryKey}"
                            onclick="togglePreferenceCategory('${pref.categoryKey}', this)">
                        ${pref.icon} ${pref.label}
                    </button>
                </c:forEach>
            </div>

            <div class="preference-sub-wrap">
                <div class="preference-sub" id="preference-sub">
                    <span class="pref-empty">상위 카테고리를 먼저 선택해 주세요</span>
                </div>
            </div>

            <div class="preference-summary hidden" id="preference-summary"></div>
        </div>

        <%-- ── 루트 그리드 ── --%>
        <div class="route-grid" id="route-grid">
            <c:choose>
                <c:when test="${empty routes}">
                    <div class="empty-state"><div class="empty-icon">🗺️</div><p>조건에 맞는 루트가 없어요</p></div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="route" items="${routes}">
                        <c:set var="routeType" value="${null}"/>
                        <c:forEach var="type" items="${travelerTypes}">
                            <c:if test="${type.typeId == route.typeId}"><c:set var="routeType" value="${type}"/></c:if>
                        </c:forEach>

                        <%-- ✅ 상세 페이지 이동 링크 연결 (기존 스타일 유지) --%>
                        <div class="route-card" style="cursor:pointer" 
                             onclick="location.href='${pageContext.request.contextPath}/routes/${route.id}'">
                            
                            <div class="route-head">
                                <div class="traveler-av ${not empty route.representativeImageUrl ? 'has-photo' : ''}" style="background:${not empty routeType ? routeType.bgColor : '#f0f0f0'}">
                                    <c:choose>
                                        <c:when test="${not empty route.representativeImageUrl}">
                                            <img src="${route.representativeImageUrl}" alt="대표 여행지 사진" loading="lazy" />
                                        </c:when>
                                        <c:otherwise>☁️</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="traveler-info">
                                    <div class="t-name">${route.userName}</div>
                                </div>
                                <c:if test="${not empty route.matchScore}">
                                    <div class="match-pct">
                                        <div class="match-num" style="color:${route.matchScore >= 80 ? 'var(--green)' : 'var(--primary-blue)'}">${route.matchScore}%</div>
                                        <div class="match-label">취향 매칭</div>
                                    </div>
                                </c:if>
                            </div>

                            <c:if test="${not empty route.matchScore}">
                                <div class="match-bar-wrap">
                                    <div class="match-bar-bg">
                                        <div class="match-bar-fill" style="width:${route.matchScore}%; background:${route.matchScore >= 80 ? 'var(--green)' : 'var(--primary-blue)'}"></div>
                                    </div>
                                </div>
                            </c:if>

                            <div class="route-body">
                                <div class="route-title-row">
                                    <div class="route-title">${route.title}</div>
                                    <c:if test="${route.planStatus eq 'PLANNING' || route.planStatus eq 'COMPLETED'}">
                                        <span class="route-plan-status route-status-${route.planStatus}">
                                            <c:choose>
                                                <c:when test="${route.planStatus eq 'PLANNING'}">계획 중</c:when>
                                                <c:otherwise>완료</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:if>
                                </div>
                                <div class="route-desc">${route.description}</div>
                                <div class="route-steps">
                                    <c:forEach var="step" items="${route.steps}" varStatus="st">
                                        <span class="route-step">${step}</span><c:if test="${!st.last}"><span class="route-arrow">→</span></c:if>
                                    </c:forEach>
                                </div>
                                <div class="tags">
                                    <c:forEach var="tagEntry" items="${route.tags}">
                                        <span class="tag tag-place">${tagEntry.value}</span>
                                    </c:forEach>
                                </div>
                            </div>

                            <div class="route-foot">
                                <div class="route-stats">
                                    <div class="route-stat route-save-count" data-route-id="${route.id}">🔖 ${route.savedCount}명 저장</div>
                                </div>
                                <button class="btn-save-route" onclick="event.stopPropagation(); saveRoute(${route.id}, this)">저장</button>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<jsp:include page="/WEB-INF/views/fragments/mainPage-Footer.jsp" />

<script>
    const csrfHeader = '${_csrf.headerName}';
    const csrfToken = '${_csrf.token}';
    const contextPath = '${pageContext.request.contextPath}';

    const preferenceCategoryLabelMap = {};
    <c:forEach var="pref" items="${preferenceCategories}">
        preferenceCategoryLabelMap['${pref.categoryKey}'] = '${pref.label}';
    </c:forEach>

    const selectedPreferenceCategories = new Set();
    let selectedPreferenceTagCategory = '';
    let selectedPreferenceTagCode = '';
    let selectedPreferenceTagName = '';
    let appliedPreferenceCategory = '';
    let appliedPreferenceTagCode = '';
    let appliedPreferenceTagName = '';

    function togglePersonalTags() {
        const toggleButton = document.getElementById('personal-meta-toggle');
        if (!toggleButton) {
            return;
        }

        const extraTags = document.querySelectorAll('.meta-extra-tag');
        if (!extraTags.length) {
            return;
        }

        const isExpanded = toggleButton.getAttribute('aria-expanded') === 'true';
        const nextExpanded = !isExpanded;

        extraTags.forEach(tag => {
            tag.classList.toggle('hidden', !nextExpanded);
        });

        toggleButton.setAttribute('aria-expanded', nextExpanded ? 'true' : 'false');
        toggleButton.innerHTML = nextExpanded
            ? '접기 <span class="meta-arrow">‹</span>'
            : '전체보기 <span class="meta-arrow">›</span>';
    }

    function applyRouteFilters() {
        const params = new URLSearchParams();
        if (appliedPreferenceCategory) {
            params.append('prefCategory', appliedPreferenceCategory);
        }
        if (appliedPreferenceTagCode) {
            params.append('prefTagCode', appliedPreferenceTagCode);
        }

        const query = params.toString();
        const url = contextPath + '/routes/filter' + (query ? ('?' + query) : '');
        fetch(url)
            .then(res => res.json())
            .then(routes => renderRouteGrid(routes))
            .catch(() => showToast('오류가 발생했어요'));
    }

    function clearSelectedPreferenceTag() {
        selectedPreferenceTagCategory = '';
        selectedPreferenceTagCode = '';
        selectedPreferenceTagName = '';
    }

    function togglePreferenceCategory(categoryKey, btn) {
        const normalizedCategory = categoryKey ? String(categoryKey).trim() : '';
        if (!normalizedCategory) {
            return;
        }

        if (selectedPreferenceCategories.has(normalizedCategory)) {
            selectedPreferenceCategories.delete(normalizedCategory);
            if (btn) {
                btn.classList.remove('active');
            }
        } else {
            selectedPreferenceCategories.add(normalizedCategory);
            if (btn) {
                btn.classList.add('active');
            }
        }

        const subWrap = document.getElementById('preference-sub');
        if (selectedPreferenceCategories.size === 0) {
            clearSelectedPreferenceTag();
            if (subWrap) {
                subWrap.innerHTML = '<span class="pref-empty">상위 카테고리를 먼저 선택해 주세요</span>';
            }
            return;
        }

        loadPreferenceTags(Array.from(selectedPreferenceCategories));
    }

    function loadPreferenceTags(categoryKeys) {
        const subWrap = document.getElementById('preference-sub');
        if (!subWrap) {
            return;
        }

        if (!Array.isArray(categoryKeys) || categoryKeys.length === 0) {
            subWrap.innerHTML = '<span class="pref-empty">상위 카테고리를 먼저 선택해 주세요</span>';
            return;
        }

        const requests = categoryKeys.map(category =>
            fetch(contextPath + '/routes/preference-tags?category=' + encodeURIComponent(category))
                .then(res => (res.ok ? res.json() : []))
                .then(tags => ({
                    categoryKey: category,
                    tags: Array.isArray(tags) ? tags : []
                }))
                .catch(() => ({
                    categoryKey: category,
                    tags: []
                }))
        );

        Promise.all(requests)
            .then(results => {
                renderPreferenceTagChips(results);
            })
            .catch(() => {
                subWrap.innerHTML = '<span class="pref-empty">세부 취향을 불러오지 못했습니다.</span>';
                showToast('세부 취향을 불러오지 못했습니다.');
            });
    }

    function renderPreferenceTagChips(categoryResults) {
        const subWrap = document.getElementById('preference-sub');
        if (!subWrap) {
            return;
        }

        subWrap.innerHTML = '';
        if (!categoryResults || categoryResults.length === 0) {
            clearSelectedPreferenceTag();
            subWrap.innerHTML = '<span class="pref-empty">선택 가능한 세부 취향이 없습니다.</span>';
            return;
        }

        const validGroups = [];
        categoryResults.forEach(result => {
            const categoryKey = result && result.categoryKey ? String(result.categoryKey) : '';
            if (!categoryKey || !selectedPreferenceCategories.has(categoryKey)) {
                return;
            }

            const sourceTags = Array.isArray(result.tags) ? result.tags : [];
            const tags = [];
            sourceTags.forEach(tag => {
                const tagCode = tag && tag.tagCode ? String(tag.tagCode) : '';
                if (!tagCode) {
                    return;
                }
                const tagName = tag && (tag.tagName || tag.tagCode)
                    ? String(tag.tagName || tag.tagCode)
                    : tagCode;
                tags.push({
                    tagCode: tagCode,
                    tagName: tagName
                });
            });

            validGroups.push({
                categoryKey: categoryKey,
                tags: tags.slice(0, 4)
            });
        });

        if (validGroups.length === 0) {
            clearSelectedPreferenceTag();
            subWrap.innerHTML = '<span class="pref-empty">선택 가능한 세부 취향이 없습니다.</span>';
            return;
        }

        let hasActiveTag = false;
        validGroups.forEach(group => {
            const categoryKey = group.categoryKey;
            const categoryLabel = preferenceCategoryLabelMap[categoryKey] || categoryKey;

            const groupBox = document.createElement('div');
            groupBox.className = 'pref-sub-group';

            const title = document.createElement('div');
            title.className = 'pref-sub-group-title';
            title.textContent = categoryLabel;

            const chipsWrap = document.createElement('div');
            chipsWrap.className = 'pref-sub-group-chips';

            if (!group.tags || group.tags.length === 0) {
                const emptyText = document.createElement('span');
                emptyText.className = 'pref-empty';
                emptyText.textContent = '선택 가능한 세부 취향이 없습니다.';
                chipsWrap.appendChild(emptyText);
            } else {
                group.tags.forEach(tag => {
                    const button = document.createElement('button');
                    button.type = 'button';
                    button.className = 'pref-chip pref-sub-chip';
                    button.textContent = tag.tagName;
                    if (selectedPreferenceTagCategory === categoryKey && selectedPreferenceTagCode === tag.tagCode) {
                        button.classList.add('active');
                        hasActiveTag = true;
                    }
                    button.addEventListener('click', () => selectPreferenceTag(categoryKey, tag.tagCode, tag.tagName, button));
                    chipsWrap.appendChild(button);
                });
            }

            groupBox.appendChild(title);
            groupBox.appendChild(chipsWrap);
            subWrap.appendChild(groupBox);
        });

        if (!hasActiveTag) {
            clearSelectedPreferenceTag();
        }
    }

    function selectPreferenceTag(categoryKey, tagCode, tagName, btn) {
        selectedPreferenceTagCategory = categoryKey || '';
        selectedPreferenceTagCode = tagCode || '';
        selectedPreferenceTagName = tagName || selectedPreferenceTagCode;

        document.querySelectorAll('.pref-sub-chip').forEach(chip => chip.classList.remove('active'));
        if (btn) {
            btn.classList.add('active');
        }
    }

    function applyPreferenceFilter() {
        if (!selectedPreferenceTagCategory || !selectedPreferenceTagCode) {
            showToast('상위 카테고리를 선택하고 세부 취향 1개를 선택해 주세요.');
            return;
        }

        appliedPreferenceCategory = selectedPreferenceTagCategory;
        appliedPreferenceTagCode = selectedPreferenceTagCode;
        appliedPreferenceTagName = selectedPreferenceTagName;
        updatePreferenceSummary();
        applyRouteFilters();
    }

    function resetPreferenceFilter() {
        selectedPreferenceCategories.clear();
        clearSelectedPreferenceTag();
        appliedPreferenceCategory = '';
        appliedPreferenceTagCode = '';
        appliedPreferenceTagName = '';

        document.querySelectorAll('.pref-top-chip').forEach(chip => chip.classList.remove('active'));
        document.querySelectorAll('.pref-sub-chip').forEach(chip => chip.classList.remove('active'));

        const subWrap = document.getElementById('preference-sub');
        if (subWrap) {
            subWrap.innerHTML = '<span class="pref-empty">상위 카테고리를 먼저 선택해 주세요</span>';
        }

        updatePreferenceSummary();
        applyRouteFilters();
    }

    function updatePreferenceSummary() {
        const summary = document.getElementById('preference-summary');
        if (!summary) {
            return;
        }

        if (!appliedPreferenceCategory || !appliedPreferenceTagCode) {
            summary.textContent = '';
            summary.classList.add('hidden');
            return;
        }

        const categoryLabel = preferenceCategoryLabelMap[appliedPreferenceCategory] || appliedPreferenceCategory;
        summary.textContent = '적용 중: ' + categoryLabel + ' · ' + appliedPreferenceTagName;
        summary.classList.remove('hidden');
    }

    function normalizeRepresentativeImageUrl(rawUrl) {
        if (rawUrl == null) {
            return '';
        }
        const trimmed = String(rawUrl).trim().replace(/\\/g, '/');
        if (!trimmed) {
            return '';
        }
        if (/^(https?:)?\/\//i.test(trimmed) || trimmed.startsWith('data:') || trimmed.startsWith('blob:')) {
            return trimmed;
        }
        if (trimmed.startsWith('/')) {
            if (contextPath && trimmed.startsWith(contextPath + '/')) {
                return trimmed;
            }
            return (contextPath || '') + trimmed;
        }

        const normalized = trimmed.replace(/^\.?\//, '');
        return contextPath ? (contextPath + '/' + normalized) : ('/' + normalized);
    }

    function escapeHtml(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function normalizeRoutePlanStatus(rawStatus) {
        if (rawStatus === null || rawStatus === undefined) {
            return '';
        }
        return String(rawStatus).trim().toUpperCase();
    }

    function renderRoutePlanStatusBadgeHtml(rawStatus) {
        const normalizedStatus = normalizeRoutePlanStatus(rawStatus);
        if (normalizedStatus !== 'PLANNING' && normalizedStatus !== 'COMPLETED') {
            return '';
        }
        const label = normalizedStatus === 'PLANNING' ? '계획 중' : '완료';
        return '<span class="route-plan-status route-status-' + normalizedStatus + '">' + label + '</span>';
    }

    function renderRouteStepsHtml(rawSteps) {
        const steps = Array.isArray(rawSteps) ? rawSteps.filter(step => step !== null && step !== undefined && String(step).trim()) : [];
        if (steps.length === 0) {
            return '<span class="route-step">등록된 코스 정보 없음</span>';
        }
        return steps.map((step, index) => {
            const arrowHtml = index < steps.length - 1 ? '<span class="route-arrow">→</span>' : '';
            return '<span class="route-step">' + escapeHtml(step) + '</span>' + arrowHtml;
        }).join('');
    }

    function renderRouteTagsHtml(rawTags) {
        const tags = [];

        if (Array.isArray(rawTags)) {
            rawTags.forEach(tag => {
                if (tag !== null && tag !== undefined && String(tag).trim()) {
                    tags.push(String(tag).trim());
                }
            });
        } else if (rawTags && typeof rawTags === 'object') {
            Object.keys(rawTags)
                .sort((a, b) => a.localeCompare(b, undefined, {numeric: true, sensitivity: 'base'}))
                .forEach(key => {
                    const value = rawTags[key];
                    if (value !== null && value !== undefined && String(value).trim()) {
                        tags.push(String(value).trim());
                    }
                });
        }

        if (tags.length === 0) {
            return '';
        }
        return tags.map(tag => '<span class="tag tag-place">' + escapeHtml(tag) + '</span>').join('');
    }

    function bindAvatarImageFallback(rootElement) {
        const root = rootElement && rootElement.querySelectorAll ? rootElement : document;
        root.querySelectorAll('.traveler-av.has-photo img').forEach(img => {
            img.addEventListener('error', function () {
                const avatar = this.closest('.traveler-av');
                if (!avatar) {
                    return;
                }
                avatar.classList.remove('has-photo');
                avatar.textContent = '☁️';
            }, { once: true });
        });
    }

    function renderRouteGrid(routes) {
        const grid = document.getElementById('route-grid');
        if (!routes || routes.length === 0) {
            grid.innerHTML = '<div class="empty-state"><div class="empty-icon">🗺️</div><p>조건에 맞는 루트가 없어요</p></div>';
            return;
        }

        const typeMap = {};
        <c:forEach var="type" items="${travelerTypes}">
            typeMap['${type.typeId}'] = { name: '${type.name}', emoji: '${type.emoji}', color: '${type.color}', bgColor: '${type.bgColor}' };
        </c:forEach>

        grid.innerHTML = routes.map(route => {
            const type = typeMap[route.typeId] || {};
            const sim = route.matchScore;
            const hasSim = sim !== null && sim !== undefined;
            const simValue = Number(sim);
            const normalizedSim = Number.isFinite(simValue) ? simValue : 0;
            const barClr = normalizedSim >= 80 ? 'var(--green)' : 'var(--primary-blue)';
            const representativeImageUrl = normalizeRepresentativeImageUrl(route.representativeImageUrl);
            const avatarInner = representativeImageUrl
                ? `<img src="\${escapeHtml(representativeImageUrl)}" alt="대표 여행지 사진" loading="lazy">`
                : '☁️';
            const avatarClass = representativeImageUrl ? 'traveler-av has-photo' : 'traveler-av';
            const safeUserName = escapeHtml(route.userName || 'Traveler');
            const safeTitle = escapeHtml(route.title || '제목 없음');
            const safeDescription = escapeHtml(route.description || '설명 정보 없음');
            const routePlanStatusBadgeHtml = renderRoutePlanStatusBadgeHtml(route.planStatus);
            const routeStepsHtml = renderRouteStepsHtml(route.steps);
            const routeTagsHtml = renderRouteTagsHtml(route.tags);
            const savedCount = Number.isFinite(Number(route.savedCount)) ? Number(route.savedCount) : 0;

            return `
            <div class="route-card" style="cursor:pointer" onclick="location.href='${pageContext.request.contextPath}/routes/\${route.id}'">
                <div class="route-head">
                    <div class="\${avatarClass}" style="background:\${type.bgColor || '#f0f0f0'}">\${avatarInner}</div>
                    <div class="traveler-info">
                        <div class="t-name">\${safeUserName}</div>
                    </div>
                    \${hasSim ? `<div class="match-pct"><div class="match-num" style="color:\${barClr}">\${normalizedSim}%</div><div class="match-label">취향 매칭</div></div>` : ''}
                </div>
                \${hasSim ? `<div class="match-bar-wrap"><div class="match-bar-bg"><div class="match-bar-fill" style="width:\${normalizedSim}%;background:\${barClr}"></div></div></div>` : ''}
                <div class="route-body">
                    <div class="route-title-row">
                        <div class="route-title">\${safeTitle}</div>
                        \${routePlanStatusBadgeHtml}
                    </div>
                    <div class="route-desc">\${safeDescription}</div>
                    <div class="route-steps">\${routeStepsHtml}</div>
                    <div class="tags">\${routeTagsHtml}</div>
                </div>
                <div class="route-foot">
                    <div class="route-stats">
                        <div class="route-stat route-save-count" data-route-id="\${route.id}">🔖 \${savedCount}명 저장</div>
                    </div>
                    <button class="btn-save-route" onclick="event.stopPropagation(); saveRoute(\${route.id}, this)">저장</button>
                </div>
            </div>`;
        }).join('');

        bindAvatarImageFallback(grid);
    }

    async function saveRoute(routeId, btn) {
        const headers = {'Content-Type': 'application/x-www-form-urlencoded'};
        if (csrfHeader && csrfToken) {
            headers[csrfHeader] = csrfToken;
        }

        try {
            const response = await fetch('${pageContext.request.contextPath}/routes/save', {
                method: 'POST',
                headers,
                body: 'routeId=' + encodeURIComponent(routeId)
            });

            const text = await response.text();
            let data = null;
            try {
                data = text ? JSON.parse(text) : {};
            } catch (e) {
                data = {success: false, message: '서버 응답을 처리하지 못했습니다.'};
            }

            if (data && data.loginRequired) {
                showToast(data.message || '로그인이 필요합니다.');
                setTimeout(() => {
                    const redirectUrl = data.redirectUrl || '/auth/login';
                    if (redirectUrl.startsWith('http')) {
                        location.href = redirectUrl;
                    } else {
                        location.href = '${pageContext.request.contextPath}' + redirectUrl;
                    }
                }, 500);
                return;
            }

            if (response.ok && data && data.success) {
                showToast(data.message || '저장되었습니다.');
                if (data.savedUserCount != null) {
                    updateSavedUserCount(routeId, data.savedUserCount);
                }
                btn.textContent = '저장됨';
                btn.disabled = true;
                return;
            }

            showToast(data && data.message ? data.message : '저장 중 오류가 발생했습니다.');
        } catch (e) {
            showToast('저장 중 오류가 발생했습니다.');
        }
    }

    function showToast(msg) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.classList.add('show');
        setTimeout(() => t.classList.remove('show'), 2200);
    }

    function updateSavedUserCount(routeId, savedUserCount) {
        const labels = document.querySelectorAll('.route-save-count[data-route-id="' + routeId + '"]');
        labels.forEach(label => {
            label.textContent = '🔖 ' + savedUserCount + '명 저장';
        });
    }

    bindAvatarImageFallback(document);
</script>

</body>
</html>
