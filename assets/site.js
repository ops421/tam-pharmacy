/* ==========================================================================
   TAM Pharmacy site behaviour
   Hero is a scroll-scrubbed JPEG frame sequence drawn on <canvas>.
   Never <video> + currentTime: browsers only seek to keyframes in a compressed
   MP4, which stutters visibly on every scrub.
   ========================================================================== */
(function () {
  'use strict';

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var hasGSAP = typeof window.gsap !== 'undefined';
  if (hasGSAP && window.ScrollTrigger) gsap.registerPlugin(ScrollTrigger);

  /* ---------------- footer year ---------------- */
  var yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  /* ---------------- nav ---------------- */
  var nav = document.getElementById('nav');
  var navToggle = document.getElementById('navToggle');
  var mobileMenu = document.getElementById('mobileMenu');

  function onScroll() {
    if (nav) nav.classList.toggle('scrolled', window.scrollY > 24);
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  if (navToggle && mobileMenu) {
    navToggle.addEventListener('click', function () {
      var open = navToggle.getAttribute('aria-expanded') === 'true';
      navToggle.setAttribute('aria-expanded', String(!open));
      navToggle.setAttribute('aria-label', open ? 'Open menu' : 'Close menu');
      mobileMenu.classList.toggle('open', !open);
    });
    mobileMenu.addEventListener('click', function (e) {
      if (e.target.tagName === 'A') {
        navToggle.setAttribute('aria-expanded', 'false');
        mobileMenu.classList.remove('open');
      }
    });
  }

  /* ---------------- loader ---------------- */
  var loader = document.getElementById('loader');
  var loaderBar = document.getElementById('loaderBar');
  function hideLoader() {
    if (!loader || loader.dataset.done) return;
    loader.dataset.done = '1';
    loader.style.opacity = '0';
    setTimeout(function () { loader.style.display = 'none'; }, 600);
  }
  // never trap the visitor behind the loader
  setTimeout(hideLoader, 6000);

  /* ---------------- hero frame sequence ---------------- */
  var canvas = document.getElementById('heroCanvas');
  var ctx = canvas ? canvas.getContext('2d') : null;
  var frames = [];
  var totalFrames = 0;
  var current = -1;

  function resize() {
    if (!canvas) return;
    var w = window.innerWidth;
    var h = window.innerHeight;
    // pixel AND style dimensions both set explicitly. No CSS %, no DPR scaling,
    // no object-fit; any of those desyncs the drawing surface from the element.
    canvas.width = w;
    canvas.height = h;
    canvas.style.width = w + 'px';
    canvas.style.height = h + 'px';
    if (current >= 0) drawFrame(current, true);
  }

  function drawFrame(idx, force) {
    if (!ctx || !frames[idx] || !frames[idx].complete || frames[idx].naturalWidth === 0) return;
    if (idx === current && !force) return;
    current = idx;
    var img = frames[idx];
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    var r = Math.max(canvas.width / img.naturalWidth, canvas.height / img.naturalHeight);
    var w = img.naturalWidth * r;
    var h = img.naturalHeight * r;
    ctx.drawImage(img, (canvas.width - w) / 2, (canvas.height - h) / 2, w, h);
  }

  function framePath(i) {
    return 'assets/frames/frame-' + String(i).padStart(4, '0') + '.jpg';
  }

  function startFrameSequence(count) {
    totalFrames = count;
    var loaded = 0;
    resize();
    window.addEventListener('resize', resize);

    for (var i = 1; i <= totalFrames; i++) {
      (function (index) {
        var img = new Image();
        img.decoding = 'async';
        img.onload = function () {
          loaded++;
          if (loaderBar) loaderBar.style.width = Math.round((loaded / totalFrames) * 100) + '%';
          if (loaded === 1) drawFrame(0, true);
          // release the page once enough frames are in to scrub smoothly
          if (loaded >= Math.ceil(totalFrames * 0.4)) hideLoader();
        };
        img.onerror = function () {
          loaded++;
          if (loaded >= Math.ceil(totalFrames * 0.4)) hideLoader();
        };
        img.src = framePath(index);
        frames[index - 1] = img;
      })(i);
    }

    if (reduceMotion || !hasGSAP) {
      // static first frame, no scrubbing
      return;
    }

    gsap.to({ frame: 0 }, {
      frame: totalFrames - 1,
      snap: 'frame',            // land on whole frame indices, no sub-frame blur
      ease: 'none',
      scrollTrigger: {
        trigger: '.hero',
        start: 'top top',
        end: 'bottom top',
        scrub: 0.3
      },
      onUpdate: function () {
        drawFrame(Math.round(this.targets()[0].frame));
      }
    });
  }

  function noFrames() {
    // Hero art hasn't been generated yet. The CSS poster gradient carries the
    // section on its own. Hide the canvas so it can't paint an empty rectangle.
    if (canvas) canvas.style.display = 'none';
    hideLoader();
  }

  if (canvas) {
    fetch('assets/frames/manifest.json', { cache: 'no-cache' })
      .then(function (r) { if (!r.ok) throw new Error('no manifest'); return r.json(); })
      .then(function (m) {
        var count = parseInt(m && m.count, 10);
        if (!count || count < 2) throw new Error('bad count');
        startFrameSequence(count);
      })
      .catch(noFrames);
  } else {
    hideLoader();
  }

  /* ---------------- hero copy ----------------
     The headline and supporting copy stay at full opacity for the whole hero.
     They used to fade out to reveal the animation, but that traded away the
     readability of the most important text on the page. Only the scroll hint
     fades, since it has done its job once you have started scrolling. */
  if (hasGSAP && !reduceMotion && document.querySelector('.scroll-hint')) {
    gsap.to('.scroll-hint', {
      opacity: 0,
      ease: 'none',
      scrollTrigger: { trigger: '.hero', start: 'top top', end: '12% top', scrub: true }
    });
  }

  /* ---------------- fade-up on scroll ---------------- */
  var fadeEls = document.querySelectorAll('.fade-up');
  if (hasGSAP && !reduceMotion && fadeEls.length) {
    fadeEls.forEach(function (el) {
      gsap.to(el, {
        opacity: 1,
        y: 0,
        duration: 0.9,
        ease: 'power3.out',
        scrollTrigger: { trigger: el, start: 'top 85%', once: true }
      });
    });
  } else {
    fadeEls.forEach(function (el) { el.style.opacity = 1; el.style.transform = 'none'; });
  }

  /* ---------------- metric counters ---------------- */
  var metrics = document.querySelectorAll('.metric strong[data-count]');
  metrics.forEach(function (el) {
    var raw = el.getAttribute('data-count') || '';
    // unfilled [[PLACEHOLDER]] tokens contain digits, so they must be excluded
    // before the numeric parse; otherwise "[[METRIC_1_VALUE]]" counts to 1.
    if (raw.indexOf('[[') !== -1) return;
    var num = parseFloat(raw.replace(/[^0-9.]/g, ''));
    // non-numeric values are left exactly as authored
    if (!isFinite(num) || num === 0 || !hasGSAP || reduceMotion) return;
    var suffix = raw.replace(/[0-9.,]/g, '');
    var obj = { v: 0 };
    gsap.to(obj, {
      v: num,
      duration: 1.6,
      ease: 'power2.out',
      scrollTrigger: { trigger: el, start: 'top 88%', once: true },
      onUpdate: function () {
        var val = num % 1 === 0 ? Math.round(obj.v) : obj.v.toFixed(1);
        el.textContent = String(val).replace(/\B(?=(\d{3})+(?!\d))/g, ',') + suffix;
      }
    });
  });

  /* ---------------- capability cards: cursor spotlight + 3D tilt ---------------- */
  if (!reduceMotion && window.matchMedia('(hover: hover)').matches) {
    document.querySelectorAll('.cap-card').forEach(function (card) {
      card.addEventListener('mousemove', function (e) {
        var r = card.getBoundingClientRect();
        card.style.setProperty('--mx', (e.clientX - r.left) + 'px');
        card.style.setProperty('--my', (e.clientY - r.top) + 'px');
        var x = (e.clientX - r.left) / r.width - 0.5;
        var y = (e.clientY - r.top) / r.height - 0.5;
        card.style.transform =
          'perspective(700px) rotateY(' + (x * 5) + 'deg) rotateX(' + (-y * 5) + 'deg)';
      });
      card.addEventListener('mouseleave', function () { card.style.transform = ''; });
    });

    /* magnetic primary CTAs */
    document.querySelectorAll('.btn-primary').forEach(function (btn) {
      btn.addEventListener('mousemove', function (e) {
        var r = btn.getBoundingClientRect();
        var cx = r.left + r.width / 2;
        var cy = r.top + r.height / 2;
        btn.style.transform =
          'translate(' + ((e.clientX - cx) * 0.22) + 'px,' + ((e.clientY - cy) * 0.28) + 'px)';
      });
      btn.addEventListener('mouseleave', function () { btn.style.transform = ''; });
    });
  }

  /* ---------------- scroll-reactive marquee ---------------- */
  var marquee = document.getElementById('marquee');
  if (marquee && !reduceMotion) {
    var content = marquee.querySelector('.marquee-content');
    if (content) {
      // duplicate until the strip covers twice the viewport, so the loop is seamless
      var clones = 0;
      while (marquee.scrollWidth < window.innerWidth * 2 && clones < 8) {
        marquee.appendChild(content.cloneNode(true));
        clones++;
      }
      var unit = content.getBoundingClientRect().width;
      var x = 0;
      var velocity = 0;

      if (hasGSAP && window.ScrollTrigger) {
        ScrollTrigger.create({
          onUpdate: function (self) { velocity = self.getVelocity() / 300; }
        });
      }
      (function tick() {
        x -= (0.55 + Math.min(Math.abs(velocity), 14) * 0.1);
        if (unit > 0 && Math.abs(x) >= unit) x += unit;
        marquee.style.transform = 'translateX(' + x + 'px)';
        velocity *= 0.92;
        requestAnimationFrame(tick);
      })();
    }
  }

  /* ---------------- process cards highlight in view ---------------- */
  if (hasGSAP && !reduceMotion) {
    document.querySelectorAll('.stack-card').forEach(function (card) {
      ScrollTrigger.create({
        trigger: card,
        start: 'top 65%',
        end: 'bottom 45%',
        onToggle: function (self) { card.classList.toggle('active', self.isActive); }
      });
    });
  }
})();
