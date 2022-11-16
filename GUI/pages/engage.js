import ScriptManager from "../components/data-management/ScriptManager";

import { useEffect } from "react";

function EngagePage() {
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

  return (
    <div>
      <h1>Engage with a host:</h1>
      <ScriptManager onNewScript={submitScript} />
      <div id="jsoneditor"></div>
    </div>
  );
}

export default EngagePage;
