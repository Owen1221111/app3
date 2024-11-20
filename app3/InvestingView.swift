import SwiftUI

struct InvestingView: View {
    var body: some View {
        VStack {
            Text("投資組合")
                .font(.title)
                .padding()
            
            // 這裡可以添加更多投資相關的內容
            Text("尚未有投資記錄")
                .foregroundColor(.gray)
        }
        .navigationTitle("投資")
    }
}

#Preview {
    InvestingView()
} 