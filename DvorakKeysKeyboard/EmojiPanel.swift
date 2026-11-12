import UIKit

enum EmojiData {
    static let categories: [(icon: String, items: [String])] = [
        ("😀", split("😀😃😄😁😆😅🤣😂🙂🙃😉😊😇🥰😍🤩😘😗😚😙🥲😋😛😜🤪😝🤑🤗🤭🫢🤫🤔🫡🤐🤨😐😑😶🫥😏😒🙄😬🤥😌😔😪🤤😴😷🤒🤕🤢🤮🤧🥵🥶🥴😵🤯🤠🥳🥸😎🤓🧐😕🫤😟🙁😮😯😲😳🥺🥹😦😧😨😰😥😢😭😱😖😣😞😓😩😫🥱😤😡😠🤬😈👿💀💩🤡👹👺👻👽👾🤖😺😸😹😻😼😽🙀😿😾🙈🙉🙊")),
        ("👍", split("👋🤚🖐✋🖖👌🤌🤏✌🤞🫰🤟🤘🤙👈👉👆👇☝👍👎✊👊🤛🤜👏🙌🫶👐🤲🤝🙏✍💅🤳💪🦾🦵🦶👂👃🧠👀👁👅👄👶🧒👦👧🧑👨👩🧓👴👵🙍🙎🙅🙆💁🙋🤦🤷👮🕵💂👷🤴👸🥷🦸🦹🧙🧚🧛🧜🧝🧞🧟💆💇🚶🏃💃🕺👯🧖")),
        ("🐶", split("🐶🐱🐭🐹🐰🦊🐻🐼🐨🐯🦁🐮🐷🐸🐵🐔🐧🐦🐤🦆🦅🦉🦇🐺🐗🐴🦄🐝🪱🐛🦋🐌🐞🐜🪰🦟🦗🕷🦂🐢🐍🦎🦖🦕🐙🦑🦐🦞🦀🐡🐠🐟🐬🐳🐋🦈🐊🐅🐆🦓🦍🐘🦛🦏🐪🐫🦒🦘🐃🐂🐄🐎🐖🐏🐑🦙🐐🦌🐕🐩🐈🐓🦃🦚🦜🦢🕊🐇🦝🦨🦡🦦🦥🐁🐀🐿🦔🌵🎄🌲🌳🌴🌱🌿☘🍀🎍🍃🍂🍁🍄🌾💐🌷🌹🥀🌺🌸🌼🌻🌞🌝🌛🌜🌚🌕🌖🌗🌘🌑🌒🌓🌔🌙⭐🌟✨⚡🔥🌈☀🌤⛅☁🌧⛈🌩❄☃⛄🌬💨💧💦☔🌊")),
        ("🍔", split("🍏🍎🍐🍊🍋🍌🍉🍇🍓🫐🍈🍒🍑🥭🍍🥥🥝🍅🍆🥑🥦🥬🥒🌶🫑🌽🥕🧄🧅🥔🍠🥐🥯🍞🥖🥨🧀🥚🍳🧈🥞🧇🥓🥩🍗🍖🌭🍔🍟🍕🥪🥙🧆🌮🌯🫔🥗🥘🍝🍜🍲🍛🍣🍱🥟🍤🍙🍚🍘🍥🥠🍢🍡🍧🍨🍦🥧🧁🍰🎂🍮🍭🍬🍫🍿🍩🍪🌰🥜🍯🥛🍼☕🍵🧃🥤🧋🍶🍺🍻🥂🍷🥃🍸🍹🍾🧊🥄🍴🍽")),
        ("⚽", split("⚽🏀🏈⚾🥎🎾🏐🏉🥏🎱🏓🏸🏒🏑🥍🏏🥅⛳🏹🎣🤿🥊🥋🎽🛹🛼⛸🥌🎿⛷🏂🏋🤼🤸⛹🤺🏇🧘🏄🏊🤽🚣🧗🚴🏆🥇🥈🥉🏅🎖🎗🎫🎟🎪🎭🎨🎬🎤🎧🎼🎹🥁🎷🎺🎸🪕🎻🎲♟🎯🎳🎮🎰🧩")),
        ("✈️", split("🚗🚕🚙🚌🚎🏎🚓🚑🚒🚐🛻🚚🚛🚜🏍🛵🚲🛴🚨🚔🚍🚘🚖🚡🚠🚟🚃🚋🚞🚝🚄🚅🚈🚂🚆🚇🚊🚉✈🛫🛬🛩💺🚀🛸🚁🛶⛵🚤🛥🛳⛴🚢⚓⛽🚧🚦🚥🗺🗿🗽🗼🏰🏯🏟🎡🎢🎠⛲⛱🏖🏝🏜🌋⛰🏔🗻🏕⛺🏠🏡🏘🏚🏗🏭🏢🏬🏣🏤🏥🏦🏨🏪🏫🏩💒🏛⛪🕌🛕🕍")),
        ("💡", split("⌚📱📲💻⌨🖥🖨🖱🕹💽💾💿📀📼📷📸📹🎥📽🎞📞☎📟📠📺📻🎙🎚🎛⏱⏲⏰🕰⌛⏳📡🔋🔌💡🔦🕯🧯🛢💸💵💴💶💷💰💳💎⚖🧰🔧🔨⚒🛠⛏🔩⚙🧱⛓🧲🔫💣🧨🪓🔪🗡⚔🛡🚬⚰⚱🏺🔮📿🧿💈⚗🔭🔬🕳🩹🩺💊💉🧬🦠🧫🧪🌡🧹🧺🧻🚽🚰🚿🛁🛀🧼🪒🧽🧴🛎🔑🗝🚪🪑🛋🛏🧸🖼🛍🛒🎁🎈🎏🎀🎊🎉🎎🏮🎐✉📩📨📧💌📥📤📦🏷📪📫📬📭📮📯📜📃📄📑🧾📊📈📉🗒🗓📆📅🗑📇🗃🗳🗄📋📁📂🗂🗞📰📓📔📒📕📗📘📙📚📖🔖🧷🔗📎🖇📐📏🧮📌📍✂🖊🖋✒🖌🖍📝✏🔍🔎🔏🔐🔒🔓")),
        ("❤️", split("❤🧡💛💚💙💜🖤🤍🤎💔❣💕💞💓💗💖💘💝💟☮✝☪🕉☸✡🔯🕎☯☦🛐⛎♈♉♊♋♌♍♎♏♐♑♒♓🆔⚛🉑☢☣📴📳🈶🈚🈸🈺🈷✴🆚💮🉐㊙㊗🈴🈵🈹🈲🅰🅱🆎🆑🅾🆘❌⭕🛑⛔📛🚫💯💢♨🚷🚯🚳🚱🔞📵🚭❗❕❓❔‼⁉🔅🔆〽⚠🚸🔱⚜🔰♻✅🈯💹❇✳❎🌐💠Ⓜ🌀💤🏧🚾♿🅿🈳🈂🛂🛃🛄🛅🚹🚺🚼🚻🚮🎦📶🈁🔣ℹ🔤🔡🔠🆖🆗🆙🆒🆕🆓0️⃣1️⃣2️⃣3️⃣4️⃣5️⃣6️⃣7️⃣8️⃣9️⃣🔟🔢#️⃣*️⃣⏏▶⏸⏯⏹⏺⏭⏮⏩⏪⏫⏬◀🔼🔽➡⬅⬆⬇↗↘↙↖↕↔↪↩⤴⤵🔀🔁🔂🔄🔃🎵🎶➕➖➗✖♾💲💱™©®〰➰➿🔚🔙🔛🔝🔜✔☑🔘🔴🟠🟡🟢🔵🟣⚫⚪🟤🔺🔻🔸🔹🔶🔷🔳🔲▪▫◾◽◼◻🟥🟧🟨🟩🟦🟪⬛⬜🟫🔈🔇🔉🔊🔔🔕📣📢💬💭🗯♠♣♥♦🃏🎴🀄")),
        ("🏳️", split("🏁🚩🎌🏴🏳🏳️‍🌈🏴‍☠️🇧🇷🇺🇸🇷🇺🇪🇸🇵🇹🇬🇧🇫🇷🇩🇪🇮🇹🇦🇷🇨🇱🇨🇴🇲🇽🇵🇪🇻🇪🇺🇾🇵🇾🇧🇴🇪🇨🇨🇺🇨🇦🇯🇵🇰🇷🇨🇳🇮🇳🇦🇺🇳🇿🇿🇦🇳🇬🇪🇬🇹🇷🇺🇦🇵🇱🇳🇱🇧🇪🇨🇭🇦🇹🇸🇪🇳🇴🇩🇰🇫🇮🇮🇪🇬🇷🇮🇱🇸🇦🇦🇪🇹🇭🇻🇳🇮🇩🇵🇭"))
    ]

    private static func split(_ s: String) -> [String] {
        s.map { String($0) }
    }
}

final class EmojiCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        label.frame = contentView.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Teclado de emojis próprio (não depende do teclado de emojis da Apple).
final class EmojiPanel: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onPick: ((String) -> Void)?
    var onBack: (() -> Void)?
    var onDelete: (() -> Void)?
    var onHaptic: (() -> Void)?

    private let collection: UICollectionView
    private let bottomBar = UIStackView()
    private var catButtons: [UIButton] = []
    private var current = 1
    private var items: [String] = []
    private var palette: Palette
    private var deleteTimer: Timer?
    private let backButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)

    private var recents: [String] { Settings.shared.recentEmoji }

    init(palette: Palette) {
        self.palette = palette
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)

        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: "c")
        collection.showsVerticalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collection)

        bottomBar.axis = .horizontal
        bottomBar.distribution = .fillEqually
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBar)

        backButton.setTitle("ABC", for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        bottomBar.addArrangedSubview(backButton)

        let cats = ["🕘"] + EmojiData.categories.map { $0.icon }
        for (i, icon) in cats.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(icon, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 20)
            b.tag = i
            b.addTarget(self, action: #selector(catTapped(_:)), for: .touchUpInside)
            bottomBar.addArrangedSubview(b)
            catButtons.append(b)
        }

        deleteButton.setImage(UIImage(systemName: "delete.left"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteDown), for: .touchDown)
        deleteButton.addTarget(self, action: #selector(deleteUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        bottomBar.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            bottomBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            bottomBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            bottomBar.heightAnchor.constraint(equalToConstant: 44),
            collection.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            collection.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            collection.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])

        apply(palette: palette)
        select(category: recents.isEmpty ? 1 : 0)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let bgGradient = CAGradientLayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        if bgGradient.superlayer == nil { layer.insertSublayer(bgGradient, at: 0) }
        bgGradient.frame = bounds
    }

    func apply(palette: Palette) {
        self.palette = palette
        // Fundo opaco (mesmo degradê do teclado) para cobrir as teclas por baixo.
        bgGradient.colors = palette.gradient.map { $0.cgColor }
        bgGradient.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 1)
        backButton.setTitleColor(palette.text, for: .normal)
        deleteButton.tintColor = palette.text
        refreshCategoryTint()
    }

    private func refreshCategoryTint() {
        for (i, b) in catButtons.enumerated() {
            b.alpha = (i == current) ? 1.0 : 0.45
        }
    }

    private func select(category: Int) {
        current = category
        items = category == 0 ? recents : EmojiData.categories[category - 1].items
        collection.reloadData()
        collection.setContentOffset(.zero, animated: false)
        refreshCategoryTint()
    }

    @objc private func backTapped() { onBack?() }

    @objc private func catTapped(_ b: UIButton) {
        onHaptic?()
        select(category: b.tag)
    }

    @objc private func deleteDown() {
        onHaptic?()
        onDelete?()
        deleteTimer?.invalidate()
        let t = Timer(timeInterval: 0.45, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let rep = Timer(timeInterval: 0.07, repeats: true) { [weak self] _ in self?.onDelete?() }
            RunLoop.main.add(rep, forMode: .common)
            self.deleteTimer = rep
        }
        RunLoop.main.add(t, forMode: .common)
        deleteTimer = t
    }

    @objc private func deleteUp() {
        deleteTimer?.invalidate()
        deleteTimer = nil
    }

    // MARK: Collection

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "c", for: indexPath) as! EmojiCell
        cell.label.text = items[indexPath.item]
        return cell
    }

    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cols: CGFloat = 8
        let w = floor((cv.bounds.width) / cols)
        return CGSize(width: w, height: 44)
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let e = items[indexPath.item]
        onHaptic?()
        var r = Settings.shared.recentEmoji.filter { $0 != e }
        r.insert(e, at: 0)
        Settings.shared.recentEmoji = r
        onPick?(e)
    }
}
