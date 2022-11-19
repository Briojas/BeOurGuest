import { Fragment, useEffect } from "react";
// import { basic_person, person } from "../../constants";

function ScriptManager(props) {
  var editor;
  var json_formatted;

  const script_template = {
    action: "Straight",
    power: 25,
    time: 0.5,
  };

  const editor_config = {
    // Enable fetching schemas via ajax
    ajax: true,

    // The schema for the editor
    schema: {
      type: "array",
      title: "Commands",
      format: "tabs",
      items: {
        title: "Command",
        headerTemplate: "{{i}}|{{self.action}}",
        format: "table",
        properties: {
          action: {
            type: "string",
            enum: ["FOR", "REV", "CW", "CCW", "STR", "STL"],
            default: "FOR",
          },
          power: {
            type: "integer",
            maximum: "99",
            minimum: "0",
            default: "35",
          },
          time: {
            type: "number",
            minimum: "0",
            default: "1.5",
          },
        },
      },
    },

    // Seed the form with a starting value
    startval: script_template,

    // Disable additional properties
    no_additional_properties: true,

    // Require all properties by default
    required_by_default: true,
  };

  async function validate() {
    // Get an array of errors from the validator
    var errors = editor.validate();

    var indicator = document.getElementById("valid_indicator");

    // Not valid
    if (errors.length) {
      indicator.style.color = "red";
      indicator.textContent = "not valid";
    }
    // Valid
    else {
      indicator.style.color = "green";
      indicator.textContent = "valid";
      json_formatted = {
        script: editor.getValue(),
      };
    }
  }

  async function submit() {
    props.onNewScript(json_formatted); //send to api
  }

  async function reset() {
    editor.setValue(script_template);
  }

  useEffect(() => {
    const container = document.getElementById("script-edit-window");
    editor = new JSONEditor(container, editor_config);

    editor.on("change", validate);
  });

  return (
    <Fragment>
      <div id="script-edit-window"></div>
      <span id="valid_indicator"></span>
      <button onClick={() => submit()}>Submit</button>
      <button onClick={() => reset()}>Reset Form</button>
    </Fragment>
  );
}

export default ScriptManager;
