import { useRef } from "react";

function Livestream(video, width, height) {
  const divRef = (useRef < HTMLDivElement) | (null > null);

  const onClick = () => {
    const iframe = document.createElement("iframe");
    iframe.setAttribute("frameborder", "0");
    iframe.setAttribute("allowfullscreen", "1");
    iframe.setAttribute(
      "allow",
      "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    );
    iframe.style.width = width;
    iframe.style.height = height;
    iframe.setAttribute(
      "src",
      `https://www.youtube.com/embed/${video}?rel=0&showinfo=1&autoplay=1`
    );
    if (divRef.current) {
      divRef.current.innerHTML = "";
      divRef.current.appendChild(iframe);
    }
  };

  return (
    <div ref={divRef} className="youtube-frame position-relative">
      <span
        onClick={onClick}
        className="ti-control-play position-absolute display-1 text-white"
      />
      <img
        onClick={onClick}
        loading="lazy"
        src={`https://img.youtube.com/vi/${video}/default.jpg`}
        alt="YouTube Video Thumbnail"
        width={width}
        height={height}
        className="shadow"
      />
    </div>
  );
}

export default Livestream;
