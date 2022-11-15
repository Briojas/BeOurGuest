import TextareaAutosize from "@mui/material/TextareaAutosize";

function EngagePage() {
  return (
    <div>
      <h1>Engage with a host:</h1>
      <TextareaAutosize
        maxRows={4}
        aria-label="maximum height"
        placeholder="Maximum 4 rows"
        defaultValue="{script:
        {
          action:[]
        }}"
        style={{ width: 600 }}
      />
    </div>
  );
}

export default EngagePage;
