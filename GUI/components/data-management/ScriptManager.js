import { Fragment, useEffect } from "react";
import TextareaAutosize from "@mui/material/TextareaAutosize";

function ScriptManager(props) {
  const json = {
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
  // useEffect(() => {
  //   if (typeof window === "undefined") {
  //     const container = document.getElementById("script-edit-window");
  //     editor = JSONEditor(container, {});
  //   }
  // }, []);

  async function submit() {
    console.log(editor.getValue());
  }

  return (
    <Fragment>
      <div id="script-edit-window"></div>
      <button onClick={() => submit()}>Submit</button>
      <div>
        <TextareaAutosize
          maxRows={24}
          aria-label="maximum height"
          placeholder="Maximum 24 rows"
          defaultValue=""
          style={{ width: 600 }}
        />
      </div>
    </Fragment>
  );
}

export default ScriptManager;
