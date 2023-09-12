/* Endings simple JS file for language-switching. */

/**
  * @function setup
  * @description Makes changes to the page based on the availability
  *              of JS. 
  */
function setup() {
    //Add the js class to the body, triggering display/layout changes.
    document.body.classList.add('js');

    //Add the change event to the view radio button set.
    let viewRadios = document.querySelectorAll('input[name="viewLang"]');
    [...viewRadios].forEach((radio) => {
        radio.addEventListener('click', (e) => { changeView(e.target.value) });
    });
    getViewFromStorage();
}


/**
  * @function getViewFromStorage
  * @description Retrieves one of the language designators from the storage value 
  *              "endingsLang". This is then used to configure what content is 
  *              visible on the page.
  */
function getViewFromStorage() {
    let view = localStorage.getItem('endingsView');
    if (view !== null) {
        let ctrl = document.querySelector('input[value="' + view + '"]');
        if (ctrl !== null) {
            ctrl.checked = 'checked';
        }
        changeView(view);
    }
    else{
        changeView('en');
    }
}

/**
  * @function changeView
  * @description This is passed a view value. If that value is one 
  *              of basic|intermediate|full, then  it uses the value to 
  *              configure a class in the document.body classList.
  * @param {String} view A string that should be equal to 'en' or 'fr'. 
  */
function changeView(view) {
    console.log(view);
    //Is it a suitable value?
    if (view.match(/^((en)|(fr))$/)) {
        //Is the page already set to this?
        if (!(document.body.classList.contains(view))) {
            document.body.classList.remove('en', 'fr');
            document.body.classList.add(view);
            localStorage.setItem('endingsView', view);
        }
    }
}

window.addEventListener('load', setup);