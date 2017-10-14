// for phoenix_html support, including form and button helpers
// copy the following scripts into your javascript bundle:
// * https://raw.githubusercontent.com/phoenixframework/phoenix_html/v2.10.0/priv/static/phoenix_html.js

const animateLine = (path) => {
  const length = path.getTotalLength();
  path.style.transition = path.style.WebkitTransition = 'none';
  path.style.strokeDasharray = length + ' ' + length;
  path.style.strokeDashoffset = length;
  path.getBoundingClientRect();
  path.style.transition = path.style.WebkitTransition = 'stroke-dashoffset .5s ease-in-out';
  path.style.strokeOpacity = '1';
  path.style.strokeDashoffset = '0';
};

const openActions = () => {
  document
    .getElementsByClassName('interactive-map')[0]
    .classList
    .add('open');
};

const resetAnimations = () => {
  const els = document.getElementsByClassName('place');
  Array.prototype.map.call(els, el => {
    el.style.strokeOpacity = '0';
  });
};

const hideActions = () => {
  document
    .getElementsByClassName('interactive-map__actions')[0]
    .style.display = 'none';

  console.log(document.getElementsByClassName('interactive-map__actions')[0])
};

const showActions = () => {
  document
    .getElementsByClassName('interactive-map__actions')[0]
    .style.display = 'block';
};


hideActions();

document.addEventListener('click', function(event) {
  event.preventDefault();

  if (!event.target.classList.contains('place')) {
    return;
  }

  showActions();
  resetAnimations();

  setTimeout(() => {
    animateLine(event.target);
    openActions();
  }, 0);
});
