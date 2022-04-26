import SwiftUI
import MapKit
import CoreLocationUI
import PopupView

struct HomeView: View {
    @StateObject var viewModel = MapViewModel()
    @ObservedObject var authManager: AuthManager
    @State var showingToast = false
    @State var toastMessage = ""
    
    func showToastMessage(toastText: String) {
        toastMessage = toastText
        showingToast = true
    }
    
    var body: some View {
        NavigationView {
            Background {
                GeometryReader { geometry in
                    VStack(spacing: 0){
                        ZStack(alignment: .top) {
                            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                                .frame(height: geometry.size.height - 390)
                                .popup(isPresented:$showingToast, type:.toast, position: .top, autohideIn: 10.0) {
                                    createTopToast(toastText: toastMessage)
                                }
                        }
                        .frame(height: geometry.size.height - 390)
                        
                        CircleButton(xOffset: geometry.size.width - 38, yOffset: -38, action: {}) {
                            NavigationLink(destination: SearchView( songs: [])){
                                Image(systemName: "plus")
                                    .font(.system(size: 28))
                            }
                        }
                        .alert(isPresented: $viewModel.alertIsPresented, content: {
                            Alert(title: Text("Location Alert"),
                                  message: Text("Please give location permissions to this app in order to locate you."),
                                  dismissButton: .default(Text("Cancel")))
                        })
                        Text(viewModel.requestManager.isLoading ? LocalizedStringKey("The Sound of \(viewModel.regionName)") : " ")
                            .frame(width: geometry.size.width, alignment: .center)
                            .font(.title2)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.3))
                        SongList(requestManager: viewModel.requestManager)
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .navigationBarBackButtonHidden(true)
            }
        }
        .task {
            if authManager.isSignedIn {
                showToastMessage(toastText: "Connected with Spotify")
            }
            viewModel.requestLocation()
        }
    }
}
