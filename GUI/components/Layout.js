import NavBar from "./navigation/NavBar";

function Layout(props) {
  return (
    <div>
      <NavBar />
      <main>{props.children}</main>
    </div>
  );
}

export default Layout;
