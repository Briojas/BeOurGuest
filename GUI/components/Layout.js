import NavBar from "./NavBar";
// import classes from "./Layout.module.css";

function Layout(props) {
  return (
    <div>
      <NavBar />
      <main>{props.children}</main>
    </div>
  );
}

export default Layout;
