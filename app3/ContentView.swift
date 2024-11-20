//
//  ContentView.swift
//  app3
//
//  Created by CheHung Liu on 2024/11/19.
//

import SwiftUI

// 添加 AssetViewModel 來管理資產數據
class AssetViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    @Published var loans: [Loan] = []
    @Published var totalAmount: Double = 0
    @Published var returnRate: Double = 0
    @Published var lastUpdateTime: Date = Date()
    
    var totalLoanAmount: Double {
        loans.reduce(0) { $0 + $1.amount }
    }
    
    func addAsset(_ asset: Asset) {
        assets.append(asset)
        calculateTotalAmount()
    }
    
    private func calculateTotalAmount() {
        totalAmount = assets.reduce(0) { $0 + $1.amount }
        lastUpdateTime = Date()
    }
    
    func refreshData() {
        // 這裡可以添加實際的數據更新邏輯
        calculateTotalAmount()
        lastUpdateTime = Date()
        objectWillChange.send()
    }
    
    // 添加獲取特定時間範圍的資產變化方法
    func getAssetChange(for timeRange: HomeView.TimeRange) -> (amount: Double, percentage: Double) {
        // 這裡將根據資產明細計算特定時間範圍的變化
        // 暫時返回模擬數據
        return (4980.40, 226.02)
    }
    
    func addLoan(_ loan: Loan) {
        loans.append(loan)
        objectWillChange.send()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = AssetViewModel()
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AssetListView(viewModel: viewModel)
                .tabItem {
                    Label("資產明細", systemImage: "list.bullet")
                }
                .tag(0)
            
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("首頁", systemImage: "house")
                }
                .tag(1)
            
            Color.clear
                .tabItem {
                    Label("更新資料", systemImage: "arrow.clockwise")
                }
                .tag(2)
                .onTapGesture {
                    viewModel.refreshData()
                }
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

// 新增資產明細頁面
struct AssetListView: View {
    @ObservedObject var viewModel: AssetViewModel
    @State private var showingInputSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.assets) { asset in
                        AssetRow(asset: asset)
                    }
                }
                
                Button(action: {
                    showingInputSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("新增資產")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("資產明細")
            .sheet(isPresented: $showingInputSheet) {
                AssetInputSheet(viewModel: viewModel)
            }
        }
    }
}

// 首先添加三個新的視圖用於詳細頁面
struct AssetDetailView: View {
    var body: some View {
        VStack {
            Text("資產現值詳細資料")
            // 這裡可以添加資產詳細資訊的內容
        }
        .navigationTitle("資產詳細")
    }
}

struct ReturnRateView: View {
    var body: some View {
        VStack {
            Text("報酬率詳細資料")
            // 這裡可以添加報酬率相關的內容
        }
        .navigationTitle("報酬率")
    }
}

struct LoanLimitView: View {
    @ObservedObject var viewModel: AssetViewModel
    @State private var showingAddLoanSheet = false
    
    var body: some View {
        List {
            ForEach(viewModel.loans) { loan in
                LoanRow(loan: loan)
            }
        }
        .navigationTitle("貸款額度")
        .navigationBarItems(trailing: Button(action: {
            showingAddLoanSheet = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddLoanSheet) {
            AddLoanView(viewModel: viewModel)
        }
    }
}

// 修改 HomeView
struct HomeView: View {
    @ObservedObject var viewModel: AssetViewModel
    @State private var selectedTimeRange: TimeRange = .year
    @State private var periodChange: (amount: Double, percentage: Double) = (4980.40, 226.02)
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var isNumbersHidden = false
    
    enum TimeRange: String, CaseIterable {
        case day = "1D"
        case week = "1W"
        case month = "1M"
        case threeMonths = "3M"
        case year = "1Y"
        case all = "All"
        
        var description: String {
            switch self {
            case .day: return "Past Day"
            case .week: return "Past Week"
            case .month: return "Past Month"
            case .threeMonths: return "Past 3 Months"
            case .year: return "Past Year"
            case .all: return "All Time"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Investing 123")
                    .font(.system(size: 35, weight: .bold))
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(isNumbersHidden ? "****" : "$\(viewModel.totalAmount, specifier: "%.2f")")
                                .font(.system(size: 35, weight: .bold))
                            
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: periodChange.amount >= 0 ? "arrow.up" : "arrow.down")
                                .foregroundColor(periodChange.amount >= 0 ? .green : .red)
                            Text(isNumbersHidden ? "****" : "$\(abs(periodChange.amount), specifier: "%.2f") (\(abs(periodChange.percentage), specifier: "%.2f")%)")
                                .foregroundColor(periodChange.amount >= 0 ? .green : .red)
                            Text(selectedTimeRange.description)
                            
                            Spacer()
                        }
                        .font(.system(size: 16))
                    }
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Image(systemName: isDarkMode ? "moon.fill" : "moon")
                                .foregroundColor(.primary)
                                .font(.system(size: 20))
                        }
                        .frame(width: 44)
                        
                        Button(action: {
                            isNumbersHidden.toggle()
                        }) {
                            Image(systemName: isNumbersHidden ? "eye.slash" : "eye")
                                .foregroundColor(.primary)
                                .font(.system(size: 20))
                        }
                        .frame(width: 44)
                    }
                }
                
                // 圖表區域
                ChartView(data: viewModel.chartData)
                    .frame(height: UIScreen.main.bounds.height * 0.24)
                
                // 時間範圍選擇器
                HStack(spacing: 20) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button(action: {
                            selectedTimeRange = range
                            updateChartData(for: range)
                        }) {
                            Text(range.rawValue)
                                .font(.system(size: 12))
                                .foregroundColor(selectedTimeRange == range ? .white : .blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    selectedTimeRange == range ? 
                                        Color.green : 
                                        Color.clear
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
                VStack(spacing: 12) {
                    // 資產現值
                    NavigationLink(destination: AssetDetailView()) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("資產現值")
                                .font(.system(size: 16))
                            Text(isNumbersHidden ? "****" : "$ \(viewModel.totalAmount, specifier: "%.2f")")
                                .font(.system(size: 16, weight: .bold))
                            Text("更新時間: \(viewModel.lastUpdateTime, style: .time)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    
                    // 報酬率按鈕
                    NavigationLink(destination: ReturnRateView()) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("報酬率")
                                .font(.system(size: 16))
                            Text(isNumbersHidden ? "****" : "\(viewModel.returnRate, specifier: "%.2f")%")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(viewModel.returnRate >= 0 ? .green : .red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    
                    // 貸款額度按鈕
                    NavigationLink(destination: LoanLimitView(viewModel: viewModel)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("貸款額度")
                                .font(.system(size: 16))
                            Text(isNumbersHidden ? "****" : "$ \(viewModel.totalLoanAmount, specifier: "%.2f")")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func updateChartData(for timeRange: TimeRange) {
        // 這裡將根據選擇的時間範圍更新數據
        // 模擬數據，實際應該從資產明細中計算
        switch timeRange {
        case .day:
            periodChange = (100.50, 5.25)
        case .week:
            periodChange = (520.30, 25.75)
        case .month:
            periodChange = (1200.80, 55.40)
        case .threeMonths:
            periodChange = (2500.60, 115.80)
        case .year:
            periodChange = (4980.40, 226.02)
        case .all:
            periodChange = (6000.00, 275.50)
        }
    }
}

// 新增圖表視圖
struct ChartView: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let step = geometry.size.width / CGFloat(data.count - 1)
                let height = geometry.size.height
                
                // 找出數據範圍
                let max = data.max() ?? 1
                let min = data.min() ?? 0
                let range = max - min
                
                // 繪製路徑
                path.move(to: CGPoint(
                    x: 0,
                    y: height - (CGFloat(data[0] - min) / CGFloat(range)) * height
                ))
                
                for index in 1..<data.count {
                    let point = CGPoint(
                        x: step * CGFloat(index),
                        y: height - (CGFloat(data[index] - min) / CGFloat(range)) * height
                    )
                    path.addLine(to: point)
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
        .padding()
    }
}

// 在 AssetViewModel 中添加圖表數據
extension AssetViewModel {
    // 模擬圖表數據
    var chartData: [Double] {
        // 這裡可以根據實際資產數據生成圖表數據
        return [2000, 2100, 4000, 7000, 6500, 5000, 7183.93]
    }
}

// 更新 AssetInputSheet，添加更多欄位
struct AssetInputSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AssetViewModel
    @State private var assetName = ""
    @State private var assetAmount = ""
    @State private var assetType = "現金" // 可以添加更多資產類型
    
    let assetTypes = ["現金", "股票", "基金", "房地產"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("資產資訊")) {
                    TextField("資產名稱", text: $assetName)
                    TextField("金額", text: $assetAmount)
                        .keyboardType(.decimalPad)
                    Picker("資產類型", selection: $assetType) {
                        ForEach(assetTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                }
            }
            .navigationTitle("新增資產")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("儲存") {
                    if let amount = Double(assetAmount) {
                        viewModel.addAsset(Asset(name: assetName, amount: amount))
                        dismiss()
                    }
                }
            )
        }
    }
}

// 資產列表項目
struct AssetRow: View {
    let asset: Asset
    
    var body: some View {
        HStack {
            Text(asset.name)
            Spacer()
            Text("$ \(asset.amount, specifier: "%.2f")")
        }
    }
}

// 更新 CustomTabButton 添加動作
struct CustomTabButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.system(size: 10))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SummaryView: View {
    var body: some View {
        Text("報酬率頁面")
    }
}

// 新增設定頁面
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("一般設定")) {
                    NavigationLink("個人資料", destination: Text("個人資料設定"))
                    NavigationLink("通知設定", destination: Text("通知設定"))
                    NavigationLink("顯示設定", destination: Text("顯示設定"))
                }
                
                Section(header: Text("其他")) {
                    NavigationLink("關於", destination: Text("關於本應用"))
                    NavigationLink("隱私政策", destination: Text("隱私政策內容"))
                }
            }
            .navigationTitle("設定")
        }
    }
}

// 新增更新資料頁面
struct RefreshView: View {
    @ObservedObject var viewModel: AssetViewModel
    @State private var isRefreshing = false
    
    var body: some View {
        VStack {
            if isRefreshing {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                Text("更新中...")
            } else {
                Image(systemName: "arrow.clockwise.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding()
                Text("點擊更新資料")
                    .font(.headline)
            }
        }
        .onTapGesture {
            refresh()
        }
    }
    
    private func refresh() {
        isRefreshing = true
        
        // 模擬更新過程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.refreshData()
            isRefreshing = false
        }
    }
}

// 添加貸款輸入表單
struct AddLoanView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AssetViewModel
    @State private var loanName = ""
    @State private var loanAmount = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("貸款名稱", text: $loanName)
                TextField("貸款金額", text: $loanAmount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("新增貸款")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("儲存") {
                    if let amount = Double(loanAmount) {
                        viewModel.addLoan(Loan(name: loanName, amount: amount))
                        dismiss()
                    }
                }
            )
        }
    }
}

// 貸款列表項目
struct LoanRow: View {
    let loan: Loan
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(loan.name)
                    .font(.headline)
                Text(loan.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("$ \(loan.amount, specifier: "%.2f")")
                .font(.system(.body, design: .monospaced))
        }
    }
}

#Preview {
    ContentView()
}
