import UIKit

enum ShiftState {
    case off, once, locked
}

protocol KeyboardViewDelegate: AnyObject {
    /// Insere texto e devolve um "token" para poder desfazer (se virar arrasto ou long-press).
    func kbInsert(_ text: String) -> Int
    func kbUndoInsert(token: Int)
    func kbDeleteBackward()
    func kbDeleteWord()
    func kbSpace()
    func kbEnter()
    func kbShiftTapped()
    func kbPage(_ page: Page)
    func kbEmoji()
    func kbOpenSettings()
    func kbMoveCursor(_ delta: Int)
    func kbHaptic()
    func kbLanguageMenuItems() -> [String]
    func kbLanguageMenuChosen(_ item: String)
}

// MARK: - Uma tecla (só visual; os toques são tratados pelo KeyboardView)

final class KeyView: UIView {
    let def: KeyDef
    private let label = UILabel()
    private let icon = UIImageView()
    private let press = UIView()
    private var glassView: UIVisualEffectView?
    private let useGlass: Bool
    private var palette: Palette

    init(def: KeyDef, palette: Palette, glass: Bool) {
        self.def = def
        self.palette = palette
        self.useGlass = glass
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        layer.cornerCurve = .continuous

        #if compiler(>=6.2)
        if glass, #available(iOS 26.0, *) {
            let ev = UIVisualEffectView(effect: KeyView.glassEffect(special: def.isSpecial, palette: palette))
            ev.isUserInteractionEnabled = false
            ev.clipsToBounds = true
            ev.layer.cornerCurve = .continuous
            addSubview(ev)
            glassView = ev
        }
        #endif

        press.alpha = 0
        press.isUserInteractionEnabled = false
        addSubview(press)

        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        addSubview(label)

        icon.contentMode = .scaleAspectFit
        addSubview(icon)

        apply(palette: palette)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    #if compiler(>=6.2)
    @available(iOS 26.0, *)
    private static func glassEffect(special: Bool, palette: Palette) -> UIGlassEffect {
        let g = UIGlassEffect()
        if special { g.tintColor = palette.glassTint }
        return g
    }
    #endif

    func apply(palette: Palette) {
        self.palette = palette
        label.textColor = palette.text
        icon.tintColor = palette.text
        press.backgroundColor = palette.pressFill

        if useGlass {
            backgroundColor = .clear
            #if compiler(>=6.2)
            if #available(iOS 26.0, *) {
                glassView?.effect = KeyView.glassEffect(special: def.isSpecial, palette: palette)
            }
            #endif
        } else {
            backgroundColor = def.isSpecial ? palette.specialFill : palette.keyFill
        }
        refreshContent(shifted: false, shiftState: .off, langName: nil)
    }

    func refreshContent(shifted: Bool, shiftState: ShiftState, langName: String?) {
        let h = bounds.height > 0 ? bounds.height : 52
        switch def.action {
        case .text:
            label.isHidden = false
            icon.isHidden = true
            label.text = shifted ? def.upper : def.label
            label.font = .systemFont(ofSize: max(18, h * 0.46), weight: .regular)
        case .shift:
            label.isHidden = true
            icon.isHidden = false
            let name: String
            switch shiftState {
            case .off: name = "shift"
            case .once: name = "shift.fill"
            case .locked: name = "capslock.fill"
            }
            icon.image = UIImage(systemName: name)
        case .delete:
            label.isHidden = true
            icon.isHidden = false
            icon.image = UIImage(systemName: "delete.left")
        case .enter:
            label.isHidden = true
            icon.isHidden = false
            icon.image = UIImage(systemName: "return")
        case .emoji:
            label.isHidden = true
            icon.isHidden = false
            icon.image = UIImage(systemName: "face.smiling")
        case .page:
            label.isHidden = false
            icon.isHidden = true
            label.text = def.label
            label.font = .systemFont(ofSize: max(15, h * 0.34), weight: .regular)
        case .space:
            label.isHidden = false
            icon.isHidden = true
            label.text = langName.map { "‹ \($0) ›" } ?? ""
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = palette.subtext
        case .spacer:
            label.isHidden = true
            icon.isHidden = true
        }
    }

    func setPressed(_ pressed: Bool) {
        if pressed {
            press.layer.removeAllAnimations()
            press.alpha = 1
        } else {
            UIView.animate(withDuration: 0.12) { self.press.alpha = 0 }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(bounds.height * 0.22, 11)
        layer.cornerRadius = radius
        press.frame = bounds
        press.layer.cornerRadius = radius
        glassView?.frame = bounds
        glassView?.layer.cornerRadius = radius
        label.frame = bounds.insetBy(dx: 2, dy: 0)
        let s = min(bounds.height * 0.42, 24)
        icon.frame = CGRect(x: (bounds.width - s) / 2, y: (bounds.height - s) / 2, width: s, height: s)
        if case .text = def.action {
            label.font = .systemFont(ofSize: max(18, bounds.height * 0.46), weight: .regular)
        }
    }
}

// MARK: - Balão do long-press

final class PopupView: UIView {
    private(set) var items: [String]
    private(set) var selected = 0
    private var cells: [UILabel] = []
    private let cols: Int
    private let rowsCount: Int
    private let cellW: CGFloat
    private let cellH: CGFloat = 44
    private let extendRight: Bool
    private let palette: Palette
    private let pad: CGFloat = 6

    init(items: [String], anchor: CGRect, container: CGRect, palette: Palette, fontSize: CGFloat = 24) {
        self.items = items
        self.palette = palette
        self.cols = max(1, min(items.count, 9))
        self.rowsCount = Int(ceil(Double(items.count) / Double(max(1, min(items.count, 9)))))
        let maxW = (container.width - 8 - 2 * pad) / CGFloat(max(1, min(items.count, 9)))
        self.cellW = min(max(anchor.width, 36), maxW)
        self.extendRight = anchor.midX < container.midX
        super.init(frame: .zero)

        let width = CGFloat(cols) * cellW + 2 * pad
        let height = CGFloat(rowsCount) * cellH + 2 * pad

        var x = extendRight ? anchor.midX - cellW / 2 - pad : anchor.midX + cellW / 2 + pad - width
        x = max(4, min(x, container.width - width - 4))
        var y = anchor.minY - height - 8
        y = max(0, y)
        frame = CGRect(x: x, y: y, width: width, height: height)

        backgroundColor = palette.popupBg
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)
        isUserInteractionEnabled = false

        for (i, item) in items.enumerated() {
            let row = i / cols
            let col = i % cols
            let displayCol = extendRight ? col : (cols - 1 - col)
            let lbl = UILabel(frame: CGRect(
                x: pad + CGFloat(displayCol) * cellW,
                y: pad + CGFloat(rowsCount - 1 - row) * cellH,
                width: cellW, height: cellH))
            lbl.text = item
            lbl.textAlignment = .center
            lbl.font = .systemFont(ofSize: fontSize)
            lbl.textColor = palette.isDark ? .white : .black
            lbl.layer.cornerRadius = 8
            lbl.layer.cornerCurve = .continuous
            lbl.clipsToBounds = true
            lbl.adjustsFontSizeToFitWidth = true
            lbl.minimumScaleFactor = 0.6
            addSubview(lbl)
            cells.append(lbl)
        }
        updateHighlight()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var selectedItem: String? { items.indices.contains(selected) ? items[selected] : nil }

    /// `point` está nas coordenadas do KeyboardView.
    func select(at point: CGPoint) {
        let local = convert(point, from: superview)
        var best = selected
        var bestD = CGFloat.greatestFiniteMagnitude
        for (i, c) in cells.enumerated() {
            let dx = local.x - c.center.x
            let dy = local.y - c.center.y
            let d = dx * dx + dy * dy
            if d < bestD { bestD = d; best = i }
        }
        if best != selected {
            selected = best
            updateHighlight()
        }
    }

    private func updateHighlight() {
        for (i, c) in cells.enumerated() {
            c.backgroundColor = (i == selected) ? palette.accent : .clear
            c.textColor = (i == selected) ? .white : (palette.isDark ? .white : .black)
        }
    }
}

// MARK: - O teclado (recebe TODOS os toques; sem "espaço morto" entre teclas)

final class KeyboardView: UIView {
    weak var delegate: KeyboardViewDelegate?

    var lang: Lang = .en {
        didSet { if oldValue != lang { rebuild() } }
    }
    var page: Page = .letters {
        didSet { rebuild() }
    }
    var shiftState: ShiftState = .off {
        didSet { refreshLabels() }
    }
    var palette: Palette = Theme.palette(isDark: true, preset: 0)
    var style: KeyStyle = .glass

    private var rowsData: [[KeyDef]] = []
    private var keyViews: [[KeyView?]] = []
    private var rects: [[CGRect]] = []
    private var host: UIView?

    private let topInset: CGFloat = 6
    private let sideInset: CGFloat = 4
    private let hGap: CGFloat = 6
    private let vGap: CGFloat = 8

    private let hintLabel = UILabel()
    private var popup: PopupView?
    fileprivate weak var popupOwner: TouchState?

    fileprivate enum Mode { case pending, swiping, popup, cursor, consumed }

    fileprivate final class TouchState {
        let r: Int
        let c: Int
        let key: KeyDef
        let start: CGPoint
        var lastX: CGFloat
        var mode: Mode = .pending
        var token: Int?
        var timer: Timer?
        var repeatTimer: Timer?
        var repeatCount = 0
        var cursorAccum: CGFloat = 0
        let shiftAtDown: ShiftState

        init(r: Int, c: Int, key: KeyDef, start: CGPoint, shift: ShiftState) {
            self.r = r
            self.c = c
            self.key = key
            self.start = start
            self.lastX = start.x
            self.shiftAtDown = shift
        }
    }

    fileprivate var states: [UITouch: TouchState] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = .clear

        hintLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        hintLabel.textAlignment = .center
        hintLabel.layer.cornerRadius = 12
        hintLabel.clipsToBounds = true
        hintLabel.alpha = 0
        hintLabel.isUserInteractionEnabled = false
        addSubview(hintLabel)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Todos os toques vão para este view, não importa qual subview está embaixo.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        bounds.contains(point) ? self : nil
    }

    // MARK: Construção

    private var glassActive: Bool {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) { return style == .glass }
        #endif
        return false
    }

    func apply(palette: Palette, style: KeyStyle) {
        self.palette = palette
        self.style = style
        hintLabel.backgroundColor = palette.popupBg
        hintLabel.textColor = palette.isDark ? .white : .black
        rebuild()
    }

    func rebuild() {
        cancelAllTouches()
        host?.removeFromSuperview()
        host = nil
        keyViews = []

        rowsData = Layouts.rows(page: page, lang: lang)

        let hostView: UIView
        let parent: UIView
        #if compiler(>=6.2)
        if glassActive, #available(iOS 26.0, *) {
            let effect = UIGlassContainerEffect()
            effect.spacing = 0
            let ev = UIVisualEffectView(effect: effect)
            ev.isUserInteractionEnabled = false
            hostView = ev
            parent = ev.contentView
        } else {
            hostView = UIView()
            parent = hostView
        }
        #else
        hostView = UIView()
        parent = hostView
        #endif
        hostView.frame = bounds
        hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostView.isUserInteractionEnabled = false
        insertSubview(hostView, at: 0)
        host = hostView

        for row in rowsData {
            var views: [KeyView?] = []
            for def in row {
                if def.isSpacer {
                    views.append(nil)
                } else {
                    let kv = KeyView(def: def, palette: palette, glass: glassActive)
                    parent.addSubview(kv)
                    views.append(kv)
                }
            }
            keyViews.append(views)
        }
        setNeedsLayout()
        layoutIfNeeded()
        refreshLabels()
    }

    func refreshLabels() {
        let shifted = shiftState != .off
        for row in keyViews {
            for kv in row {
                kv?.refreshContent(shifted: shifted, shiftState: shiftState, langName: lang.displayName)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        host?.frame = bounds
        guard !rowsData.isEmpty, bounds.width > 0 else { return }

        let n = CGFloat(rowsData.count)
        let rowH = (bounds.height - 2 * topInset - (n - 1) * vGap) / n
        rects = []
        for (r, row) in rowsData.enumerated() {
            let units = row.reduce(0) { $0 + $1.width }
            let pitch = (bounds.width - 2 * sideInset + hGap) / units
            let y = topInset + CGFloat(r) * (rowH + vGap)
            var x = sideInset
            var rowRects: [CGRect] = []
            for (c, def) in row.enumerated() {
                let rect = CGRect(x: x, y: y, width: def.width * pitch - hGap, height: rowH)
                rowRects.append(rect)
                keyViews[r][c]?.frame = rect
                x += def.width * pitch
            }
            rects.append(rowRects)
        }
        bringSubviewToFront(hintLabel)
        if let p = popup { bringSubviewToFront(p) }
    }

    // MARK: Hit-test: a tecla mais próxima do dedo (nunca cai em "espaço vazio")

    private func keyAt(_ p: CGPoint) -> (Int, Int)? {
        guard !rowsData.isEmpty, rects.count == rowsData.count else { return nil }
        let n = CGFloat(rowsData.count)
        let rowH = (bounds.height - 2 * topInset - (n - 1) * vGap) / n
        let step = rowH + vGap
        var r = Int(floor((p.y - topInset + vGap / 2) / step))
        r = max(0, min(r, rowsData.count - 1))

        var best: Int?
        var bestD = CGFloat.greatestFiniteMagnitude
        for (c, def) in rowsData[r].enumerated() where !def.isSpacer {
            let rect = rects[r][c]
            let dx: CGFloat
            if p.x < rect.minX { dx = rect.minX - p.x }
            else if p.x > rect.maxX { dx = p.x - rect.maxX }
            else { dx = 0 }
            if dx < bestD { bestD = dx; best = c }
        }
        guard let c = best else { return nil }
        return (r, c)
    }

    // MARK: Textos

    private func shiftedLabel(_ key: KeyDef) -> String {
        shiftState != .off ? key.upper : key.label
    }

    private func popupItems(for key: KeyDef) -> [String] {
        let shifted = shiftState != .off
        let base = shifted ? key.upper : key.label
        let alts = shifted ? key.alts.map { Layouts.upperAlt($0) } : key.alts
        return [base] + alts
    }

    private func after(_ seconds: TimeInterval, _ block: @escaping () -> Void) -> Timer {
        let t = Timer(timeInterval: seconds, repeats: false) { _ in block() }
        RunLoop.main.add(t, forMode: .common)
        return t
    }

    // MARK: Toques

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let p = t.location(in: self)
            guard let (r, c) = keyAt(p) else { continue }
            let key = rowsData[r][c]
            let st = TouchState(r: r, c: c, key: key, start: p, shift: shiftState)
            states[t] = st
            keyViews[r][c]?.setPressed(true)
            delegate?.kbHaptic()
            handleDown(st)
        }
    }

    private func handleDown(_ st: TouchState) {
        let key = st.key
        switch key.action {
        case .text:
            // A letra sai NO TOQUE (não ao soltar) — ajuda quem digita rápido.
            st.token = delegate?.kbInsert(shiftedLabel(key))
            if !key.alts.isEmpty {
                st.timer = after(0.32) { [weak self, weak st] in
                    guard let self = self, let st = st else { return }
                    self.beginPopup(st)
                }
            }
        case .delete:
            delegate?.kbDeleteBackward()
            st.timer = after(0.45) { [weak self, weak st] in
                guard let self = self, let st = st else { return }
                self.startDeleteRepeat(st)
            }
        case .space:
            st.timer = after(0.35) { [weak self, weak st] in
                guard let self = self, let st = st, st.mode == .pending else { return }
                st.mode = .cursor
                self.delegate?.kbHaptic()
                self.showHint("◂ cursor ▸")
            }
        case .emoji:
            st.timer = after(0.40) { [weak self, weak st] in
                guard let self = self, let st = st else { return }
                self.beginLanguageMenu(st)
            }
        case .page:
            if key.label == "123" && page == .letters {
                st.timer = after(Settings.shared.settingsHoldSeconds) { [weak self, weak st] in
                    guard let self = self, let st = st, st.mode == .pending else { return }
                    st.mode = .consumed
                    self.keyViews[st.r][st.c]?.setPressed(false)
                    self.delegate?.kbHaptic()
                    self.delegate?.kbOpenSettings()
                }
            }
        case .shift, .enter, .spacer:
            break
        }
    }

    private func startDeleteRepeat(_ st: TouchState) {
        guard st.mode == .pending else { return }
        let t = Timer(timeInterval: 0.07, repeats: true) { [weak self, weak st] _ in
            guard let self = self, let st = st else { return }
            st.repeatCount += 1
            if st.repeatCount <= 15 {
                self.delegate?.kbDeleteBackward()
            } else if st.repeatCount % 3 == 0 {
                self.delegate?.kbDeleteWord()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        st.repeatTimer = t
    }

    private func beginPopup(_ st: TouchState) {
        guard st.mode == .pending, popup == nil else { return }
        // Tira a letra que já tinha saído no toque; o balão decide o que entra.
        if let tok = st.token {
            delegate?.kbUndoInsert(token: tok)
            st.token = nil
        }
        let items = popupItems(for: st.key)
        showPopup(items: items, anchor: rects[st.r][st.c], owner: st)
        st.mode = .popup
        delegate?.kbHaptic()
    }

    private func beginLanguageMenu(_ st: TouchState) {
        guard st.mode == .pending, popup == nil, let items = delegate?.kbLanguageMenuItems(), !items.isEmpty else { return }
        showPopup(items: items, anchor: rects[st.r][st.c], owner: st, fontSize: 18)
        st.mode = .popup
        delegate?.kbHaptic()
    }

    private func showPopup(items: [String], anchor: CGRect, owner: TouchState, fontSize: CGFloat = 24) {
        popup?.removeFromSuperview()
        let p = PopupView(items: items, anchor: anchor, container: bounds, palette: palette, fontSize: fontSize)
        addSubview(p)
        popup = p
        popupOwner = owner
    }

    private func hidePopup() {
        popup?.removeFromSuperview()
        popup = nil
        popupOwner = nil
    }

    private func showHint(_ text: String) {
        hintLabel.text = "  \(text)  "
        hintLabel.sizeToFit()
        let w = hintLabel.bounds.width + 8
        hintLabel.frame = CGRect(x: (bounds.width - w) / 2, y: 2, width: w, height: 24)
        hintLabel.alpha = 1
        bringSubviewToFront(hintLabel)
    }

    private func hideHint() {
        UIView.animate(withDuration: 0.15) { self.hintLabel.alpha = 0 }
    }

    private func canSwipe(_ key: KeyDef) -> Bool {
        switch key.action {
        case .text, .shift, .enter, .page, .emoji: return true
        default: return false
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            guard let st = states[t] else { continue }
            let p = t.location(in: self)

            switch st.mode {
            case .popup:
                popup?.select(at: p)

            case .cursor:
                let dx = p.x - st.lastX
                st.lastX = p.x
                st.cursorAccum += dx
                let step: CGFloat = 9
                while st.cursorAccum >= step {
                    delegate?.kbMoveCursor(1)
                    st.cursorAccum -= step
                }
                while st.cursorAccum <= -step {
                    delegate?.kbMoveCursor(-1)
                    st.cursorAccum += step
                }

            case .pending:
                guard canSwipe(st.key) else { continue }
                let dx = p.x - st.start.x
                let dy = p.y - st.start.y
                if dx < -26 && abs(dx) > abs(dy) * 1.2 {
                    beginSwipe(st)
                    updateSwipeHint(distance: -dx)
                }

            case .swiping:
                updateSwipeHint(distance: st.start.x - p.x)

            case .consumed:
                break
            }
        }
    }

    private func beginSwipe(_ st: TouchState) {
        st.timer?.invalidate()
        st.timer = nil
        // Cancela a letra que já tinha saído no toque.
        if let tok = st.token {
            delegate?.kbUndoInsert(token: tok)
            st.token = nil
        }
        keyViews[st.r][st.c]?.setPressed(false)
        st.mode = .swiping
        delegate?.kbHaptic()
    }

    private func updateSwipeHint(distance: CGFloat) {
        let word = distance >= Settings.shared.wordSwipeDistance
        showHint(word ? "⌫  palavra" : "⌫  letra")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { finish(t, cancelled: false) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { finish(t, cancelled: true) }
    }

    private func finish(_ t: UITouch, cancelled: Bool) {
        guard let st = states[t] else { return }
        states[t] = nil
        st.timer?.invalidate()
        st.repeatTimer?.invalidate()
        keyViews[st.r][st.c]?.setPressed(false)

        switch st.mode {
        case .swiping:
            if !cancelled {
                let dist = st.start.x - t.location(in: self).x
                if dist >= Settings.shared.wordSwipeDistance {
                    delegate?.kbDeleteWord()
                } else {
                    delegate?.kbDeleteBackward()
                }
            }
            hideHint()

        case .popup:
            if !cancelled, let item = popup?.selectedItem {
                if case .emoji = st.key.action {
                    delegate?.kbLanguageMenuChosen(item)
                } else {
                    _ = delegate?.kbInsert(item)
                }
            }
            hidePopup()

        case .cursor:
            hideHint()

        case .consumed:
            break

        case .pending:
            guard !cancelled else { return }
            switch st.key.action {
            case .space: delegate?.kbSpace()
            case .shift: delegate?.kbShiftTapped()
            case .enter: delegate?.kbEnter()
            case .page(let p): delegate?.kbPage(p)
            case .emoji: delegate?.kbEmoji()
            default: break
            }
        }
    }

    private func cancelAllTouches() {
        for (_, st) in states {
            st.timer?.invalidate()
            st.repeatTimer?.invalidate()
        }
        states.removeAll()
        hidePopup()
        hintLabel.alpha = 0
    }
}
