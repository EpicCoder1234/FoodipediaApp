import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                                    .edgesIgnoringSafeArea(.all)
                Image("food_background") // Make sure to add this image to your Assets
                    .resizable()
                    .scaledToFill()
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Foodipedia")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 20)
                    
                    NavigationLink(destination: SignInView()) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
