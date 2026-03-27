# 서브메뉴 기능 구현 계획서

## 1. 아키텍처 개요

### 현재 구조

```
OverlayEntry (controller가 생성)
  └─ Stack
       ├─ Positioned.fill(Listener)  ← 바깥 클릭 감지
       └─ ContextMenuOverlay         ← 메뉴 패널 1개 (Positioned)
```

### 변경 후 구조

```
OverlayEntry (controller가 생성, builder가 _ContextMenuRoot만 반환)
  └─ _ContextMenuRoot (StatefulWidget - 전체 메뉴 트리 상태 관리)
       └─ Stack
            ├─ Positioned.fill(Listener)           ← 바깥 클릭 → 전체 닫힘
            ├─ _ContextMenuPanel(depth=0)           ← 루트 메뉴
            ├─ _ContextMenuPanel(depth=1)           ← 서브메뉴 (열려 있을 때)
            └─ _ContextMenuPanel(depth=2)           ← 서브-서브메뉴 (열려 있을 때)
```

핵심: 모든 메뉴 패널이 **하나의 OverlayEntry 안의 Stack**에 존재. `hideMenu()` 한 번이면 전부 제거됨. 컨트롤러 변경 최소화.

### Controller OverlayEntry 변경 (이중 Stack 방지)

기존 controller는 OverlayEntry builder 내부에서 Stack을 직접 구성함. 변경 후에는 `_ContextMenuRoot`에 Stack 관리를 **완전 위임**하고, controller의 builder는 `_ContextMenuRoot`만 반환한다.

```dart
// context_menu_controller.dart - 변경 후
_currentMenuEntry = OverlayEntry(
  builder: (context) => _ContextMenuRoot(
    items: items,
    position: position,
    config: effectiveConfig,
    areaConstraints: areaConstraints,
  ),
);
```

기존의 Stack, Positioned.fill(Listener), ContextMenuOverlay 구성은 전부 `_ContextMenuRoot.build()` 내부로 이동. controller에는 Stack이 없다.

---

## 2. 모델 변경

### ContextMenuItem - 새 팩토리 추가

```dart
class ContextMenuItem {
  // 기존 필드 유지 + 추가:
  final List<ContextMenuItem>? children;
  bool get isSubmenu => children != null && children!.isNotEmpty;

  /// 기본 생성자 - children = null 명시
  const ContextMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.textColor,
    this.isDivider = false,
  }) : isCustom = false,
       builder = null,
       customHeight = null,
       children = null;

  /// 디바이더 - children = null 명시
  const ContextMenuItem.divider()
      : label = '',
        icon = null,
        onTap = null,
        enabled = false,
        textColor = null,
        isDivider = true,
        isCustom = false,
        builder = null,
        customHeight = null,
        children = null;

  /// 커스텀 위젯 - children = null 명시
  const ContextMenuItem.custom({
    required WidgetBuilder this.builder,
    this.customHeight,
  }) : label = '',
       icon = null,
       onTap = null,
       enabled = true,
       textColor = null,
       isDivider = false,
       isCustom = true,
       children = null;

  /// 서브메뉴 아이템 생성
  const ContextMenuItem.submenu({
    required this.label,
    required List<ContextMenuItem> this.children,
    this.icon,
    this.enabled = true,
    this.textColor,
  }) : assert(children.length > 0, 'submenu children must not be empty'),
       isDivider = false,
       isCustom = false,
       builder = null,
       customHeight = null,
       onTap = null;  // 서브메뉴 아이템은 onTap 없음
}
```

제약사항:

- `submenu` 아이템은 `onTap`을 가질 수 없음 (호버/탭 시 서브메뉴를 여는 게 동작)
- `children` 안에 `divider`, `custom`, `submenu` 모두 가능 (재귀 구조)
- `children`이 빈 리스트면 assert 실패 (빈 서브메뉴 방지)
- 기존 3개 생성자 모두 `children = null` 명시 초기화

### ContextMenuConfig - 서브메뉴 설정 추가

```dart
class ContextMenuConfig {
  // 기존 필드 유지 + 추가:
  final Duration submenuOpenDelay;          // 호버 후 열리기까지 딜레이 (기본 200ms)
  final Duration submenuCloseDelay;         // 호버 벗어나고 닫히기까지 딜레이 (기본 300ms)
  final double submenuHorizontalOffset;     // 부모-서브메뉴 간 수평 간격 (기본 -4, 살짝 겹침)
  final ContextMenuAnimationBuilder? submenuAnimationBuilder;  // 서브메뉴 전용 애니메이션 (기본: null → slideRight 사용)
  final int maxSubmenuDepth;                // 최대 서브메뉴 중첩 깊이 (기본 5, 무한재귀 방지)
}
```

`submenuHorizontalOffset`이 음수(-4)인 이유: 부모 메뉴와 서브메뉴 사이에 간격이 있으면 마우스 이동 시 호버가 끊어짐. 살짝 겹치면 자연스러움.

`submenuAnimationBuilder`가 별도인 이유: 루트 메뉴는 popup/scale이 자연스럽지만 서브메뉴는 slideRight/slideLeft가 자연스러움. null이면 서브메뉴 방향에 따라 자동 선택 (오른쪽 열림 → slideRight, 왼쪽 열림 → slideLeft).

`maxSubmenuDepth`: 프로그래밍 실수로 순환 참조가 생기거나 과도한 중첩을 방지. 기본값 5.

---

## 3. 핵심 위젯: _ContextMenuRoot

위치: `context_menu_overlay.dart` 안에 private으로 정의

### 상태 구조

```dart
class _MenuLevel {
  final List<ContextMenuItem> items;
  Offset position;              // 조정될 수 있음 (post-frame 측정 후)
  final int parentItemIndex;    // 부모 메뉴에서 몇 번째 아이템이 이 서브메뉴를 열었는지
  bool measured;                // post-frame 측정 완료 여부
  final GlobalKey menuKey;      // RenderBox 측정용
  final GlobalKey? triggerItemKey;  // 서브메뉴를 연 아이템의 GlobalKey (위치 계산용)
  final int generation;         // 측정 콜백 검증용 세대 카운터
  bool openedLeft;              // 왼쪽으로 열렸는지 여부 (애니메이션 방향 결정용)
}
```

```dart
class _ContextMenuRootState extends State<_ContextMenuRoot> {
  List<_MenuLevel> _menuStack = [];    // index 0 = 루트 메뉴
  Timer? _openTimer;                    // 서브메뉴 열기 대기 타이머
  Map<int, Timer> _closeTimers = {};   // depth별 닫기 타이머
  int _generation = 0;                  // post-frame 측정 검증용 세대 카운터
}
```

### 타이머 생명주기 관리 (Critical)

```dart
@override
void dispose() {
  // 모든 타이머 반드시 취소
  _openTimer?.cancel();
  for (final timer in _closeTimers.values) {
    timer.cancel();
  }
  _closeTimers.clear();
  super.dispose();
}

/// 닫기 타이머 설정 - 기존 타이머가 있으면 반드시 먼저 취소
void _setCloseTimer(int depth, Timer timer) {
  _closeTimers[depth]?.cancel();  // 기존 타이머 취소 (누락 시 유령 타이머 버그)
  _closeTimers[depth] = timer;
}

/// 모든 타이머 콜백에서 반드시 호출
bool _safeToUpdate() => mounted;
```

모든 Timer 콜백은 아래 패턴을 따름:

```dart
_openTimer = Timer(config.submenuOpenDelay, () {
  if (!_safeToUpdate()) return;  // disposed 상태 체크
  // ... setState 호출 ...
});
```

### Post-Frame 측정 검증 (Race Condition 방지)

```dart
void _schedulePostFrameMeasurement(int depth) {
  final expectedGeneration = ++_generation;
  final expectedMenuKey = _menuStack[depth].menuKey;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    // 세대 불일치 → 이미 다른 메뉴로 교체됨
    if (depth >= _menuStack.length) return;
    if (_menuStack[depth].menuKey != expectedMenuKey) return;

    final renderBox = expectedMenuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _handlePanelMeasured(depth, renderBox);
  });
}
```

`_handlePanelMeasured`에서 triggerItemKey를 사용해 아이템 bounds를 읽음:

```dart
void _handlePanelMeasured(int depth, RenderBox menuRenderBox) {
  final level = _menuStack[depth];
  final menuSize = menuRenderBox.size;

  if (depth == 0) {
    // 루트 메뉴: 기존 MenuPositionCalculator.calculate() 사용
    final newPos = MenuPositionCalculator.calculate(...);
    setState(() {
      level.position = newPos;
      level.measured = true;
    });
  } else {
    // 서브메뉴: triggerItemKey로 부모 아이템 bounds 조회
    final triggerRenderBox = level.triggerItemKey?.currentContext?.findRenderObject() as RenderBox?;
    if (triggerRenderBox == null) return;

    final triggerItemBounds = triggerRenderBox.localToGlobal(Offset.zero) & triggerRenderBox.size;

    // 부모 패널 bounds 조회
    final parentLevel = _menuStack[depth - 1];
    final parentRenderBox = parentLevel.menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (parentRenderBox == null) return;

    final parentBounds = parentRenderBox.localToGlobal(Offset.zero) & parentRenderBox.size;

    final newPos = MenuPositionCalculator.calculateSubmenu(
      parentPanelBounds: parentBounds,
      triggerItemBounds: triggerItemBounds,
      submenuSize: menuSize,
      screenSize: MediaQuery.of(context).size,
      areaConstraints: widget.areaConstraints,
      padding: widget.config.screenPadding,
      horizontalOffset: widget.config.submenuHorizontalOffset,
    );

    // 왼쪽으로 열렸는지 판단 (애니메이션 방향 결정)
    final openedLeft = newPos.dx < parentBounds.left;

    setState(() {
      level.position = newPos;
      level.measured = true;
      level.openedLeft = openedLeft;
    });
  }
}
```

### _getActiveChildIndex 정의

```dart
int? _getActiveChildIndex(int depth) {
  if (depth + 1 < _menuStack.length) {
    return _menuStack[depth + 1].parentItemIndex;
  }
  return null;
}
```

### 렌더링

```dart
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // 바깥 클릭 감지 (기존과 동일)
      Positioned.fill(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => RootContextMenuController().hideMenu(),
          child: IgnorePointer(),
        ),
      ),
      // 각 depth의 메뉴 패널
      for (var i = 0; i < _menuStack.length; i++)
        _ContextMenuPanel(
          key: _menuStack[i].menuKey,
          items: _menuStack[i].items,
          position: _menuStack[i].position,
          config: widget.config,
          depth: i,
          measured: _menuStack[i].measured,
          openedLeft: _menuStack[i].openedLeft,
          activeChildIndex: _getActiveChildIndex(i),
          onSubmenuItemHoverEnter: (itemIndex, itemKey, children) =>
              _handleSubmenuItemHover(i, itemIndex, itemKey, children),
          onSubmenuItemHoverExit: (itemIndex) =>
              _handleSubmenuItemUnhover(i, itemIndex),
          onNonSubmenuItemHoverEnter: () => _handleNonSubmenuItemHover(i),
          onPanelMouseEnter: () => _handlePanelEnter(i),
          onPanelMouseExit: () => _handlePanelExit(i),
          areaConstraints: widget.areaConstraints,
        ),
    ],
  );
}
```

---

## 4. _ContextMenuPanel 위젯 스펙

기존 `ContextMenuOverlay`를 리팩토링한 위젯. 단일 메뉴 패널의 렌더링만 담당.

### 입력 (Props)

```dart
class _ContextMenuPanel extends StatelessWidget {
  final List<ContextMenuItem> items;
  final Offset position;
  final ContextMenuConfig config;
  final int depth;
  final bool measured;                    // post-frame 측정 완료 여부
  final bool openedLeft;                  // 왼쪽으로 열렸는지 (애니메이션 방향)
  final int? activeChildIndex;            // 현재 열린 서브메뉴의 부모 아이템 인덱스
  final Rect? areaConstraints;

  // 콜백들 (용도별 분리)
  final void Function(int itemIndex, GlobalKey itemKey, List<ContextMenuItem> children) onSubmenuItemHoverEnter;  // 서브메뉴 아이템 호버 → 서브메뉴 열기 요청
  final void Function(int itemIndex) onSubmenuItemHoverExit;   // 서브메뉴 아이템 호버 이탈 → 닫기 타이머 시작
  final VoidCallback onNonSubmenuItemHoverEnter;               // 일반 아이템 호버 → 열린 서브메뉴 즉시 닫기
  final VoidCallback onPanelMouseEnter;                        // 패널 마우스 진입 → 닫기 타이머 취소
  final VoidCallback onPanelMouseExit;                         // 패널 마우스 이탈 → 닫기 타이머 시작
}
```

### 렌더링 구조

```dart
@override
Widget build(BuildContext context) {
  return Positioned(
    left: position.dx,
    top: position.dy,
    child: Opacity(
      opacity: measured ? 1.0 : 0.0,
      child: MouseRegion(
        onEnter: (_) => onPanelMouseEnter(),
        onExit: (_) => onPanelMouseExit(),
        child: TweenAnimationBuilder<double>(
          key: measured ? const ValueKey('animated') : null,
          tween: Tween(begin: measured ? 0.0 : 1.0, end: 1.0),
          duration: measured ? config.animationDuration : Duration.zero,
          builder: (context, value, child) {
            final animBuilder = _resolveAnimationBuilder();
            return animBuilder(value, child!);
          },
          child: _buildMenuContent(),
        ),
      ),
    ),
  );
}
```

### 애니메이션 방향 해결

```dart
ContextMenuAnimationBuilder _resolveAnimationBuilder() {
  if (depth == 0) {
    // 루트 메뉴: config의 animationBuilder 또는 기본 popup
    return config.animationBuilder ?? ContextMenuAnimations.popup;
  }
  // 서브메뉴: 전용 빌더가 있으면 사용, 없으면 방향에 따라 자동 선택
  if (config.submenuAnimationBuilder != null) {
    return config.submenuAnimationBuilder!;
  }
  return openedLeft
      ? ContextMenuAnimations.slideLeft   // 왼쪽으로 열리면 slideLeft
      : ContextMenuAnimations.slideRight; // 오른쪽으로 열리면 slideRight
}
```

> `ContextMenuAnimations.slideLeft`는 새로 추가해야 함 (기존 slideRight의 반대 방향).

### 메뉴 바디 빌드 (_buildMenuContent)

기존 `ContextMenuOverlay._buildMenuContent()`와 동일하되, 각 아이템에 콜백 전달:

```dart
Widget _buildMenuContent() {
  final menuBody = Container(
    constraints: BoxConstraints(
      minWidth: config.minWidth,
      maxWidth: config.maxWidth,
    ),
    padding: config.menuPadding,
    child: IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++)
            ContextMenuItemWidget(
              item: items[i],
              config: config,
              itemIndex: i,
              isActiveSubmenuParent: activeChildIndex == i,
              onSubmenuHoverEnter: items[i].isSubmenu
                  ? (itemKey) => onSubmenuItemHoverEnter(i, itemKey, items[i].children!)
                  : null,
              onSubmenuHoverExit: items[i].isSubmenu
                  ? () => onSubmenuItemHoverExit(i)
                  : null,
              onNonSubmenuItemHoverEnter: !items[i].isSubmenu && !items[i].isDivider
                  ? () => onNonSubmenuItemHoverEnter()
                  : null,
            ),
        ],
      ),
    ),
  );

  // Material 래핑 (기존 boxShadow/elevation 분기 동일)
  // ...
}
```

### 소유권 정리

| 책임 | 소유자 |
|------|--------|
| 메뉴 스택 상태 관리 | `_ContextMenuRoot` |
| post-frame 측정 스케줄링 | `_ContextMenuRoot` |
| 위치 계산 | `_ContextMenuRoot._handlePanelMeasured()` |
| 타이머 관리 | `_ContextMenuRoot` |
| 단일 패널 렌더링 | `_ContextMenuPanel` |
| 애니메이션 | `_ContextMenuPanel` (방향 해결 포함) |
| 아이템 렌더링 + 호버 감지 | `ContextMenuItemWidget` |

---

## 5. 호버 타이밍 로직 (버그 방지 핵심)

### 시나리오별 동작

| 이벤트 | 동작 |
|--------|------|
| 서브메뉴 아이템(depth N) 호버 진입 | depth N+1 닫기 타이머 취소 → N+1에 이미 다른 서브메뉴 열려있으면 즉시 닫기 → 열기 타이머 시작(200ms) |
| 서브메뉴 아이템(depth N) 호버 이탈 | depth N+1 닫기 타이머 시작(300ms) |
| 서브메뉴 패널(depth N) 마우스 진입 | depth N 닫기 타이머 취소 |
| 서브메뉴 패널(depth N) 마우스 이탈 | depth N 닫기 타이머 시작(300ms) |
| 일반 아이템(depth N) 호버 진입 | depth N+1 이상 즉시 닫기 + 열기 타이머 취소 |
| 서브메뉴 아이템 클릭(터치) | 즉시 열기 (타이머 무시) |
| 일반 아이템 클릭 | 전체 메뉴 닫기 + 콜백 실행 (기존과 동일) |
| 바깥 클릭 | controller.hideMenu() → OverlayEntry 제거 → 전체 소멸 |

### 타이머 충돌 방지 규칙

1. **열기 타이머는 전역 1개**: `_openTimer` 하나만 존재. 새 열기 요청 시 이전 타이머 반드시 취소.
2. **닫기 타이머는 depth별 1개**: `_closeTimers[depth]` 설정 시 해당 depth의 기존 타이머를 반드시 먼저 취소 (`_setCloseTimer` 메서드 사용).
3. **모든 콜백에서 `mounted` 체크**: dispose 이후 setState 호출 방지.

### 300ms 닫기 딜레이가 해결하는 문제

```
┌──────────┐          ┌──────────┐
│ Parent   │  ← gap → │ Submenu  │
│ Menu     │          │          │
│  Item >  │~~mouse~~>│  Sub1    │
│          │          │  Sub2    │
└──────────┘          └──────────┘
```

마우스가 부모 아이템에서 서브메뉴 패널로 이동할 때 **중간 갭**을 지남. 이 때 부모 아이템의 `onExit`이 발생하지만, 300ms 딜레이 덕분에 서브메뉴 패널의 `onEnter`가 먼저 도착해서 닫기 타이머를 취소함.

`submenuHorizontalOffset: -4` (살짝 겹침)도 이 갭을 줄이는 데 도움.

---

## 6. 서브메뉴 위치 계산

### MenuPositionCalculator.calculateSubmenu() 추가

```dart
static Offset calculateSubmenu({
  required Rect parentPanelBounds,   // 부모 메뉴 패널의 글로벌 Rect
  required Rect triggerItemBounds,   // 호버된 아이템의 글로벌 Rect
  required Size submenuSize,         // 서브메뉴 측정 크기
  required Size screenSize,
  Rect? areaConstraints,
  EdgeInsets padding = EdgeInsets.zero,
  double horizontalOffset = -4,
})
```

### 위치 결정 순서

1. **기본**: 부모 메뉴 오른쪽, 아이템 상단 정렬
   - `left = parentPanelBounds.right + horizontalOffset`
   - `top = triggerItemBounds.top`

2. **오른쪽 공간 부족**: 부모 메뉴 왼쪽으로 전환
   - `left = parentPanelBounds.left - submenuSize.width - horizontalOffset`

3. **왼쪽도 부족**: 왼쪽 경계에 클램프
   - `left = area.left + padding.left`

4. **아래 공간 부족**: 위로 시프트
   - `top = area.bottom - submenuSize.height - padding.bottom`

5. **위도 부족**: 상단에 클램프
   - `top = area.top + padding.top`

### 반환값에 방향 정보 포함

위치 계산 결과에 왼쪽/오른쪽 열림 방향 정보가 필요함 (애니메이션 방향 결정용). 두 가지 접근 가능:

- **방법 A**: `calculateSubmenu()`가 `({Offset position, bool openedLeft})` 레코드 반환
- **방법 B**: 호출자가 `newPos.dx < parentBounds.left`로 직접 판단

→ **방법 B 채택** (단순함, 별도 반환 타입 불필요)

### Post-Frame 측정 (기존 패턴 재활용)

서브메뉴도 루트 메뉴와 동일한 패턴:

1. `opacity: 0`으로 렌더링
2. `_ContextMenuRoot`가 `addPostFrameCallback` 스케줄링
3. 콜백에서 **세대 카운터 + menuKey 검증** 후 측정 진행
4. `calculateSubmenu()`으로 위치 계산 (triggerItemKey로 아이템 bounds 조회)
5. `setState()` → `opacity: 1` + 애니메이션 시작

---

## 7. ContextMenuItemWidget 변경

### 서브메뉴 아이템 렌더링

```dart
// 기존 Row에 화살표 추가
Row(
  children: [
    if (item.icon != null) ...[icon, spacing],
    Expanded(child: Text(item.label)),
    if (item.isSubmenu)
      Opacity(
        opacity: item.enabled ? 0.6 : 0.3,
        child: Icon(Icons.chevron_right, size: 14),
      ),
  ],
)
```

### 새로운 Props

```dart
class ContextMenuItemWidget extends StatefulWidget {
  final ContextMenuItem item;
  final ContextMenuConfig config;
  final int itemIndex;                          // 패널 내 인덱스
  final bool isActiveSubmenuParent;             // 이 아이템의 서브메뉴가 열려있는지
  final void Function(GlobalKey itemKey)? onSubmenuHoverEnter;       // 서브메뉴 아이템 호버 진입 → 서브메뉴 열기 요청
  final VoidCallback? onSubmenuHoverExit;                           // 서브메뉴 아이템 호버 이탈 → 닫기 타이머 시작
  final VoidCallback? onNonSubmenuItemHoverEnter;                   // 일반 아이템 호버 진입 → 열린 서브메뉴 즉시 닫기
}
```

### 호버 동작

```dart
class _ContextMenuItemWidgetState extends State<ContextMenuItemWidget> {
  bool _isHovered = false;
  final GlobalKey _itemKey = GlobalKey();  // 이 아이템의 bounds 측정용

  @override
  Widget build(BuildContext context) {
    // ... divider, custom 렌더링 (기존 동일) ...

    return Padding(
      padding: widget.config.itemMargin,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          if (widget.item.isSubmenu && widget.item.enabled) {
            widget.onSubmenuHoverEnter?.call(_itemKey);
          } else if (!widget.item.isSubmenu && !widget.item.isDivider) {
            widget.onNonSubmenuItemHoverEnter?.call();
          }
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          if (widget.item.isSubmenu) {
            widget.onSubmenuHoverExit?.call();
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.item.isSubmenu
              ? (widget.item.enabled
                  ? () => widget.onSubmenuHoverEnter?.call(_itemKey)  // 터치: 즉시 열기
                  : null)
              : (widget.item.enabled
                  ? () { /* 기존 onTap 로직 */ }
                  : null),
          child: Container(
            key: _itemKey,  // bounds 측정용
            // ...
          ),
        ),
      ),
    );
  }
}
```

### 활성 상태 표시

서브메뉴가 열려있는 아이템은 호버 색상 유지:

```dart
color: (_isHovered || widget.isActiveSubmenuParent) && widget.item.enabled
    ? widget.config.hoverColor
    : null,
```

---

## 8. 파일별 변경 요약

| 파일 | 변경 내용 |
|------|----------|
| `context_menu_item.dart` | `children` 필드 + `isSubmenu` getter + `submenu()` 팩토리 + 기존 3개 생성자에 `children = null` + assert |
| `context_menu_config.dart` | `submenuOpenDelay`, `submenuCloseDelay`, `submenuHorizontalOffset`, `submenuAnimationBuilder`, `maxSubmenuDepth` 추가 |
| `context_menu_controller.dart` | OverlayEntry builder가 `_ContextMenuRoot`만 반환하도록 변경 (기존 inline Stack 제거) |
| `context_menu_overlay.dart` | `_ContextMenuRoot` (상태관리+타이머+측정) + `_ContextMenuPanel` (단일 패널 렌더링)으로 리팩토링. 기존 `ContextMenuOverlay` 클래스는 제거 |
| `context_menu_item_widget.dart` | 서브메뉴 아이템 렌더링 (화살표) + 호버 콜백 + 활성 상태 + itemKey |
| `context_menu_animation.dart` | `slideLeft` 애니메이션 추가 |
| `menu_position_calculator.dart` | `calculateSubmenu()` 정적 메서드 추가 |
| `flutter_root_context_menu.dart` | 변경 없음 |
| `context_menu_helpers.dart` | 변경 없음 |

---

## 9. 엣지 케이스 & 버그 방지

| # | 엣지 케이스 | 처리 방법 |
|---|-----------|----------|
| 1 | 빠른 호버 전환 (아이템 A→B 빠르게) | 이전 열기 타이머 취소 → 새 타이머 시작. `_openTimer`는 전역 1개만 존재 |
| 2 | 부모↔서브메뉴 간 마우스 이동 (갭 통과) | 300ms 닫기 딜레이 + 패널 mouseEnter가 타이머 취소 |
| 3 | 깊은 중첩 (depth 2+) | 스택 구조로 자연 지원. depth N에서 다른 아이템 호버 시 N+1 이상 모두 제거. `maxSubmenuDepth`로 상한 제한 |
| 4 | disabled 서브메뉴 아이템 | 호버해도 서브메뉴 안 열림, 회색 텍스트 + 화살표도 회색 (opacity 0.3) |
| 5 | 서브메뉴 안에 divider/custom | 일반 아이템과 동일하게 처리 (children은 그냥 `List<ContextMenuItem>`) |
| 6 | 화면 모서리에서 서브메뉴 | `calculateSubmenu()`가 좌/우 반전 + 상/하 클램프 처리 |
| 7 | Route 변경 시 | RouteObserver → `hideMenu()` → OverlayEntry 제거 → 전부 소멸 |
| 8 | 터치 디바이스 (호버 없음) | 서브메뉴 아이템 탭 시 즉시 서브메뉴 열기 (타이머 무시) |
| 9 | 열린 서브메뉴의 부모 아이템 재호버 | 이미 열려있으면 아무것도 안 함 (중복 열기 방지) |
| 10 | 메뉴 열린 상태에서 우클릭으로 새 메뉴 | controller.showMenu()이 먼저 hideMenu() 호출 → 기존 전체 정리 → 새 메뉴 |
| 11 | 서브메뉴 애니메이션 방향 | 오른쪽 열림 → slideRight, 왼쪽 열림 → slideLeft. `openedLeft` 플래그로 판단 |
| 12 | post-frame 측정 전 빠른 호버 이탈 | 세대 카운터 + menuKey 검증으로 잘못된 측정 방지. mounted 체크 |
| 13 | Timer 콜백이 dispose 후 실행 | `dispose()`에서 모든 타이머 취소 + 모든 콜백에서 `mounted` 체크 |
| 14 | `_closeTimers` 덮어쓰기 시 이전 타이머 누수 | `_setCloseTimer()` 메서드가 기존 타이머를 먼저 cancel한 후 새 타이머 설정 |
| 15 | hideMenu() → showMenu() 연속 호출 | 각 `_ContextMenuRoot` 인스턴스는 독립 State. 이전 인스턴스의 dispose는 프레임워크가 보장. 공유 상태 없음 |
| 16 | 빈 children 리스트 | `ContextMenuItem.submenu()` assert로 컴파일타임/런타임 방지 |
| 17 | children에 순환 참조 | `maxSubmenuDepth` (기본 5)로 무한 재귀 방지. depth 초과 시 서브메뉴 열지 않음 |
| 18 | Material shadow가 MouseRegion 밖 | `submenuHorizontalOffset: -4` 겹침으로 좌우 완화. 상하는 shadow 영역이 좁아 실용적 문제 없음 |

---

## 10. 알려진 제한사항 (향후 개선)

현재 기획 범위 밖이지만, 추후 고려할 사항:

| 항목 | 설명 |
|------|------|
| **RTL 레이아웃** | 현재 서브메뉴는 항상 오른쪽 우선. RTL 로케일에서는 왼쪽 우선이어야 함. `calculateSubmenu`에 `TextDirection` 파라미터 추가 필요. 기존 메뉴도 RTL 미지원이므로 별도 이슈로 처리. |
| **키보드 내비게이션** | 화살표 키로 아이템 이동, Enter로 선택, →로 서브메뉴 열기, ←로 서브메뉴 닫기, Escape로 전체 닫기. 기존 메뉴도 미지원이므로 별도 이슈로 처리. |
| **화면 리사이즈/회전** | 메뉴 열린 상태에서 윈도우 크기 변경 시 위치가 틀어짐. `WidgetsBindingObserver.didChangeMetrics`로 감지하여 메뉴 닫기 또는 재계산 필요. 별도 이슈로 처리. |

---

## 11. Public API 변경 (Breaking Changes 없음)

추가만:

- `ContextMenuItem.submenu()` 생성자
- `ContextMenuConfig`에 optional 필드 5개 (모두 기본값 있음)
- `ContextMenuAnimations.slideLeft` 추가

기존 API 100% 호환: 서브메뉴를 안 쓰면 동작이 완전히 동일.

---

## 12. 사용 예시

```dart
showRootContextMenu(
  context: context,
  position: details.globalPosition,
  items: [
    ContextMenuItem(label: 'Copy', icon: Icon(Icons.copy, size: 18), onTap: () {}),
    ContextMenuItem(label: 'Paste', icon: Icon(Icons.paste, size: 18), onTap: () {}),
    ContextMenuItem.divider(),
    ContextMenuItem.submenu(
      label: 'Share',
      icon: Icon(Icons.share, size: 18),
      children: [
        ContextMenuItem(label: 'Email', onTap: () {}),
        ContextMenuItem(label: 'Slack', onTap: () {}),
        ContextMenuItem.submenu(
          label: 'Social',
          children: [
            ContextMenuItem(label: 'Twitter', onTap: () {}),
            ContextMenuItem(label: 'Facebook', onTap: () {}),
          ],
        ),
      ],
    ),
    ContextMenuItem(label: 'Delete', textColor: Colors.red, onTap: () {}),
  ],
);
```
