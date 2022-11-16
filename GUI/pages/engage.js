// import ScriptManager from "../components/data-management/ScriptManager";

import { useEffect } from "react";

function EngagePage() {
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

  async function submitScript(json) {
    //build json file and send to api
    const response = await fetch("/api/new-script", {
      method: "POST",
      body: JSON.stringify(json),
    });

    const data = await response.json();

    console.log(data);

    //submit to contract via metamask?
  }

  useEffect(() => {
    const container = document.getElementById("jsoneditor");
    var editor = new JSONEditor(container, json);
  }, []);

  return (
    <div>
      <h1>Engage with a host:</h1>
      {/* <ScriptManager onNewScript={submitScript} /> */}
      <div id="jsoneditor"></div>
    </div>
  );
}

export default EngagePage;
