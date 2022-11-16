import { Fragment, useEffect } from "react";

function ScriptManager(props) {
  var editor;
  const script_template = {
    schema: {
      type: "object",
      title: "Car",
      properties: {
        make: {
          type: "string",
          enum: ["Toyota", "BMW", "Honda", "Ford", "Chevy", "VW"],
        },
        model: {
          type: "string",
        },
        year: {
          type: "integer",
          enum: [
            1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
            2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014,
          ],
          default: 2008,
        },
        safety: {
          type: "integer",
          format: "rating",
          maximum: "5",
          exclusiveMaximum: false,
          readonly: false,
        },
      },
    },
  };
  useEffect(() => {
    const container = document.getElementById("script-edit-window");
    editor = new JSONEditor(container, script_template);
  }, []);

  async function submit() {
    console.log(editor.getValue());
  }

  return (
    <Fragment>
      <div id="script-edit-window"></div>
      <button onClick={() => submit()}>Submit</button>
    </Fragment>
  );
}

export default ScriptManager;
