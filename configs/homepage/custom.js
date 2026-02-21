(function waitForLogo() {
    const logoImg = document.querySelector('.information-widget-logo img');

    if (!logoImg) {
        setTimeout(waitForLogo, 200);
        return;
    }

    const container = logoImg.closest('.information-widget-logo');
    if (!container) return;

    if (getComputedStyle(container).position === 'static') {
        container.style.position = 'relative';
    }

    // =======================
    // CONFIGURATION
    // =======================
    const catNoises = ['mao', 'maooo', 'meo!', 'mreo', 'miao', 'miaooo', 'mau', 'mauuu', 'miau', 'miauu', 'miaa', 'prr', 'mrauu'];
    const bubbleFontSize = '0.8rem';
    const bubblePadding = '0.4rem 0.7rem';
    const bubbleOffset = 4;       // px from logo
    const scaleMin = 0.8;
    const scalePop = 1.1;
    const bubbleVisibleDuration = 2000; // ms bubble is visible

    // Loop duration range (ms)
    const bubbleLoopDurationMin = 10000;  // minimum interval between pops
    const bubbleLoopDurationMax = 45000; // maximum interval between pops

    // =======================
    // CREATE BUBBLE
    // =======================
    const bubble = document.createElement('div');
    bubble.className = 'speech';
    bubble.style.opacity = 0;
    bubble.style.transform = `translateY(-50%) scale(${scaleMin})`;
    bubble.textContent = catNoises[Math.floor(Math.random() * catNoises.length)];
    container.appendChild(bubble);

    // =======================
    // INJECT CSS
    // =======================
    const style = document.createElement('style');
    style.textContent = `
        @import url('https://fonts.googleapis.com/css2?family=Comic+Neue:wght@700&display=swap');

        .information-widget-logo .speech {
            position: absolute;
            top: 50%;
            right: calc(100% + ${bubbleOffset}px);
            padding: ${bubblePadding};
            background: #fff;
            color: #000;
            border-radius: 12px;
            font-family: 'Comic Neue', Comic Sans MS, cursive;
            font-size: ${bubbleFontSize};
            white-space: nowrap;
            pointer-events: none;
            z-index: 9999;
            transition: opacity 0.2s ease, transform 0.2s ease;
        }

        .information-widget-logo .speech::after {
            content: "";
            position: absolute;
            top: 50%;
            right: -6px;
            transform: translateY(-50%);
            border-width: 6px 0 6px 6px;
            border-style: solid;
            border-color: transparent transparent transparent #fff;
        }
    `;
    document.head.appendChild(style);

    // =======================
    // SHOW/HIDE FUNCTION
    // =======================
    function popBubble() {
        // random text
        bubble.textContent = catNoises[Math.floor(Math.random() * catNoises.length)];

        // show
        bubble.style.opacity = 1;
        bubble.style.transform = `translateY(-50%) scale(${scalePop})`;

        // hide after bubbleVisibleDuration
        setTimeout(() => {
            bubble.style.opacity = 0;
            bubble.style.transform = `translateY(-50%) scale(${scaleMin})`;
        }, bubbleVisibleDuration);
    }

    // =======================
    // HELPER TO PICK RANDOM DURATION IN RANGE
    // =======================
    function randomDuration() {
        return bubbleLoopDurationMin + Math.random() * (bubbleLoopDurationMax - bubbleLoopDurationMin);
    }

    // =======================
    // LOOP FUNCTION
    // =======================
    function scheduleNextPop() {
        const nextDuration = randomDuration();
        setTimeout(() => {
            popBubble();
            scheduleNextPop(); // schedule the next one
        }, nextDuration);
    }

    // Start first pop after a random delay within range
    setTimeout(scheduleNextPop, randomDuration());
})();

