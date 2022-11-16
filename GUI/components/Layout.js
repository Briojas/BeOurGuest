import NavBar from "./navigation/NavBar";

function Layout(props) {
  return (
    <div className="">
      <NavBar />
      <main className="max-w-md mx-auto my-12">{props.children}</main>
    </div>
  );
}

export default Layout;
