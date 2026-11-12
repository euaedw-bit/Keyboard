import SwiftUI

@main
struct DvorakKeysApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var testText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Dvorak Keys")
                    .font(.largeTitle.bold())

                Text("Para ativar o teclado:")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    Text("1. Ajustes > Geral > Teclado > Teclados > Adicionar Novo Teclado")
                    Text("2. Escolha \"Dvorak Keys\"")
                    Text("3. Toque em \"Dvorak Keys\" na lista e ligue \"Permitir Acesso Completo\" (necessário para a vibração/haptic)")
                    Text("4. Em qualquer campo de texto, segure o globo e escolha o teclado")
                }
                .font(.subheadline)

                Button("Abrir Ajustes do iPhone") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)

                Text("Campo de teste:")
                    .font(.headline)
                    .padding(.top, 8)

                TextField("Toque aqui e teste o teclado", text: $testText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)

                Text("Dicas")
                    .font(.headline)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text("• Segure o botão de emoji: troca de idioma (EN / ES / PT / RU)")
                    Text("• Segure a barra de espaço e arraste: move o cursor")
                    Text("• Arraste para a esquerda em qualquer lugar do teclado: curto apaga uma letra, longo apaga a palavra")
                    Text("• Segure o botão 123 por 3 segundos: abre os ajustes do teclado")
                }
                .font(.subheadline)
            }
            .padding()
        }
    }
}
