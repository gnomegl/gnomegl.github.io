document.addEventListener("DOMContentLoaded", function () {
  const copyIcon =
    '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>';

  const checkIcon =
    '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>';

  const errorIcon =
    '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>';

  const codeBlocks = document.querySelectorAll("pre");

  codeBlocks.forEach(function (block) {
    if (block.querySelector(".code-copy-btn")) return;

    const text = (
      block.querySelector("code")
        ? block.querySelector("code").textContent
        : block.textContent
    ).trim();
    if (text.length < 5) return;

    const copyBtn = document.createElement("button");
    copyBtn.className = "code-copy-btn";
    copyBtn.innerHTML = copyIcon;
    copyBtn.title = "Copy to clipboard";
    copyBtn.setAttribute("aria-label", "Copy code");

    copyBtn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();

      const code = block.querySelector("code");
      let text = code ? code.textContent : block.textContent;

      text = text.trim();

      navigator.clipboard
        .writeText(text)
        .then(function () {
          copyBtn.innerHTML = checkIcon;
          copyBtn.classList.add("copied");

          setTimeout(function () {
            copyBtn.innerHTML = copyIcon;
            copyBtn.classList.remove("copied");
          }, 2000);
        })
        .catch(function (err) {
          // Fallback for older browsers
          const textArea = document.createElement("textarea");
          textArea.value = text;
          textArea.style.position = "fixed";
          textArea.style.left = "-999999px";
          textArea.style.top = "-999999px";
          document.body.appendChild(textArea);
          textArea.focus();
          textArea.select();

          try {
            const successful = document.execCommand("copy");
            if (successful) {
              copyBtn.innerHTML = checkIcon;
              copyBtn.classList.add("copied");
              setTimeout(function () {
                copyBtn.innerHTML = copyIcon;
                copyBtn.classList.remove("copied");
              }, 2000);
            } else {
              throw new Error("Copy command failed");
            }
          } catch (err) {
            copyBtn.innerHTML = errorIcon;
            setTimeout(function () {
              copyBtn.innerHTML = copyIcon;
            }, 2000);
          }

          document.body.removeChild(textArea);
        });
    });

    block.appendChild(copyBtn);
  });
});

