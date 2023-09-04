import Network
import SwiftUI

final class ExamplePathMonitor: ObservableObject {
    @Published private(set) var status: NWPath.Status = .unsatisfied

    let pathMonitor = NWPathMonitor()
    private let pathMonitorQueue = DispatchQueue(label: "NWPathMonitor")

    init(status: NWPath.Status = .unsatisfied) {
        self.status = status
    }

    func startMonitoring() {
        pathMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.status = path.status
            }
        }
        pathMonitor.start(queue: pathMonitorQueue)
    }
}

struct ExamplePathMonitorView: View {
    @ObservedObject var pathMonitor = ExamplePathMonitor()

    var body: some View {
        List {
            Section {
                networkLabel
            } header: {
                Text("Network Status")
            }

            Section {
                capabilities
            } header: {
                Text("Capabilities")
            }

            Section {
                interfaces
            } header: {
                Text("Interfaces")
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Network Monitor")
        .onAppear { pathMonitor.startMonitoring() }
    }

    var networkLabel: some View {
        Label(
            title: {
                Text(pathMonitor.status.message)
            },
            icon: {
                Image(systemName: pathMonitor.status.image)
                    .foregroundColor(pathMonitor.status.color)
            }
        )
    }

    var capabilities: some View {
        VStack(spacing: 12) {
            HStack {
                Text("supportsIPv4")
                Spacer()
                Text(pathMonitor.pathMonitor.currentPath.supportsIPv4 ? "YES" : "NO")
            }
            HStack {
                Text("supportsIPv6")
                Spacer()
                Text(pathMonitor.pathMonitor.currentPath.supportsIPv6 ? "YES" : "NO")
            }
            HStack {
                Text("supportsDNS")
                Spacer()
                Text(pathMonitor.pathMonitor.currentPath.supportsDNS ? "YES" : "NO")
            }
            HStack {
                Text("isExpensive")
                Spacer()
                Text(pathMonitor.pathMonitor.currentPath.isExpensive ? "YES" : "NO")
            }
            HStack {
                Text("isConstrained")
                Spacer()
                Text(pathMonitor.pathMonitor.currentPath.isConstrained ? "YES" : "NO")
            }
        }
    }

    var interfaces: some View {
        ForEach(pathMonitor.pathMonitor.currentPath.availableInterfaces, id: \.name) { interface in
            HStack {
                Text(interface.name)
                Spacer()
                Text("\(interface.type.description)")
            }
        }
    }
}
struct ExamplePathMonitor_Previews: PreviewProvider {
    static var previews: some View {
        ExamplePathMonitorView()
    }
}

extension NWPath.Status {
    var message: String {
        switch self {
        case .satisfied:
            return "Satisfied"
        case .unsatisfied:
            return "Unsatisfied"
        case .requiresConnection:
            return "requiresConnection"
        @unknown default:
            return "Not Available"
        }
    }
    var color: Color {
        switch self {
        case .satisfied:
            return .green
        case .unsatisfied:
            return .yellow
        case .requiresConnection:
            return .red
        @unknown default:
            return .red
        }
    }
    var image: String {
        switch self {
        case .satisfied:
            return "checkmark.circle"
        case .unsatisfied:
            return "exclamationmark.triangle"
        case .requiresConnection:
            return "xmark.circle"
        @unknown default:
            return "xmark.circle"
        }
    }
}

extension NWInterface.InterfaceType {
    var description: String {
        switch self {
        case .other:
            return "Other"
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "WiredEthernet"
        case .loopback:
            return "Loopback"
        @unknown default:
            return "Unknown"
        }
    }
}
