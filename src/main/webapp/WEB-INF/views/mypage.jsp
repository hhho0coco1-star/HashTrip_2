<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/css/mypage.css">
</head>
<body>

	<div id="mypage" class="page">
		<div class="mypage-container">

			<div class="profile-card">
				<div id="my-av" class="profile-avatar">👤</div>
				<h2 class="profile-name">${usersDTO.userName}</h2>
				<div id="my-badge" class="profile-badge">성향 분석 전</div>
				<p id="my-desc"
					style="color: var(--toss-grey-600); margin-top: 12px; font-size: 14px;">
					여행 취향을 설정하고 딱 맞는 여행지를 추천받으세요.</p>
				<button class="btn-action"q
					style="margin-top: 24px; background: var(--toss-grey-100); color: var(--toss-grey-800);"
					onclick="editProfile()">⚙️ 회원정보 변경</button>
			</div>

			<div class="dashboard-card">
				<h3>🎯 나의 여행 취향</h3>
				<div id="tag-managers"></div>
				<button class="btn-action" style="margin-top: 10px;">성향 다시
					분석하기</button>
			</div>

			<div class="dashboard-card">
				<h3>❤️ 찜한 여행지</h3>
				<div id="saved-sub"
					style="text-align: center; padding: 20px 0; color: var(--toss-grey-600);">
					아직 찜한 여행지가 없어요.</div>
				<div id="saved-list" class="saved-list"></div>
			</div>

			<div class="dashboard-card">
				<h3>✍️ 내가 작성한 리뷰</h3>
				<div
					style="text-align: center; padding: 30px 0; color: var(--toss-grey-600); font-size: 14px;">
					아직 작성한 리뷰가 없습니다.<br> 여행 후 소중한 경험을 공유해보세요!
				</div>
			</div>

		</div>
	</div>

	<script>
/* 1. 필요한 기초 데이터 정의 (이 데이터가 있어야 화면이 그려집니다) */
const CATS = {
    theme: { label: '테마', icon: '🏕️', color: '#3182f6', cls: 'theme-tag' },
    food: { label: '음식', icon: '🍕', color: '#ff9800', cls: 'food-tag' }
};

const ALL_TAGS = {
    theme: ['캠핑', '호캉스', '박물관', '액티비티', '바다'],
    food: ['로컬맛집', '인스타감성', '전통시장', '비건']
};

// 사용자가 현재 가지고 있는 태그 (DB에서 불러올 값)
let myTags = {
    theme: ['캠핑'],
    food: []
};

// 사용자 성향 정보
let myType = {
    emoji: '🌊',
    name: '감성 탐험가',
    desc: '여유로운 속도로 자연을 즐기며 진정한 휴식을 찾는 당신'
};

// 찜한 여행지 데이터
let savedDests = new Set([101]); 
const DESTS = [
    { id: 101, name: '제주 성산일출봉', emoji: '⛰️' }
];

/* 2. 핵심 렌더링 함수 (태그 선택/삭제 UI 생성) */
function renderMyPage() {
    // 프로필 업데이트
    if (myType) {
        document.getElementById('my-av').textContent = myType.emoji;
        document.getElementById('my-badge').textContent = `\${myType.emoji} \${myType.name}`;
        document.getElementById('my-desc').textContent = myType.desc;
    }

    // 태그 관리자 영역 생성 (이 부분이 태그 선택/삭제 버튼을 만듭니다)
    document.getElementById('tag-managers').innerHTML = Object.entries(CATS).map(([cat, info]) => {
        const mine = myTags[cat] || [];
        const avail = ALL_TAGS[cat].filter(t => !mine.includes(t));

        // 내가 가진 태그 (삭제 버튼 포함)
        const items = mine.map(t => `
            <span class="tag-item">
                \${t}
                <button class="remove-btn" onclick="removeTag('\${cat}','\${t}')">✕</button>
            </span>`).join('');

        // 추가 가능한 태그 (추가 버튼)
        const adds = avail.map(t =>
            `<button class="add-tag-btn" onclick="addTag('\${cat}','\${t}')">+ \${t}</button>`
        ).join('');

        return `
        <div class="tag-mgr-card" style="margin-bottom: 20px; border-bottom: 1px solid #f2f4f6; padding-bottom: 15px;">
            <div class="tmg-head" style="display:flex; align-items:center; gap:8px; margin-bottom:10px;">
                <span style="width:8px;height:8px;border-radius:50%;background:\${info.color}"></span>
                <span class="tmg-title" style="font-weight:700">\${info.icon} \${info.label}</span>
            </div>
            <div class="tags" style="display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px;">
                \${items || '<span style="color:#b0b8c1;font-size:13px">태그를 추가해보세요</span>'}
            </div>
            <div class="add-tag-row" style="display:flex; flex-wrap:wrap; gap:6px;">
                \${adds}
            </div>
        </div>`;
    }).join('');

    // 찜한 여행지 렌더링
    const subs = document.getElementById('saved-sub');
    const sl = document.getElementById('saved-list');
    if (savedDests.size) {
        subs.style.display = 'none';
        sl.innerHTML = [...savedDests].map(id => {
            const d = DESTS.find(x => x.id === id);
            return d ? `<span class="saved-chip" style="display:inline-block; padding:10px; background:#f2f4f6; border-radius:12px; margin-right:5px;">\${d.emoji} \${d.name}</span>` : '';
        }).join('');
    }
}

/* 3. 태그 추가/삭제 기능 */
function addTag(cat, tag) {
    if (!myTags[cat]) myTags[cat] = [];
    if (!myTags[cat].includes(tag)) {
        myTags[cat].push(tag);
        renderMyPage(); // 화면 갱신
        console.log(`\${tag} 추가됨`);
    }
}

function removeTag(cat, tag) {
    myTags[cat] = myTags[cat].filter(t => t !== tag);
    renderMyPage(); // 화면 갱신
    console.log(`\${tag} 제거됨`);
}

function editProfile() {
    alert("회원정보 수정 페이지로 이동합니다.");
}

// 페이지 로드 시 실행
window.onload = renderMyPage;
</script>

</body>
</html>