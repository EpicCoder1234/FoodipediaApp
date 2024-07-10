import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Sign Up", destination: SignUpView())
                NavigationLink("Sign In", destination: SignInView())
            }
            .navigationTitle("Foodie App")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
