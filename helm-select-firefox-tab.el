(setq helm-firefox-tabs-js-helper-functions "
function list_tab_labels() {
	var tabs = gBrowser.tabContainer.childNodes;
	var labels = [];

	for( i = 0; i < tabs.length; i++) {
		labels.push(tabs[i].label);
	}
	return labels;
}

function choose_tab_by_name(name) {
	var tabContainer = window.getBrowser().tabContainer;
	var tabs = tabContainer.childNodes;
	var numTabs = tabs.length;
	var startIndex = tabContainer.selectedIndex;
	var testIndex;

	for (i = 0; i < numTabs - 1; i++) {
		testIndex = (startIndex + i + 1) % numTabs;
		if (tabs[testIndex].label === name) {
			tabContainer.selectedItem = tabs[testIndex];
			break;
		}
	}
}")

(defun helm-firefox-tabs-init-js ()
  (comint-send-string
   (inferior-moz-process)
   helm-firefox-tabs-js-helper-functions))

(helm-firefox-tabs-init-js)

(defun-moz-controller-command helm-firefox-tabs-js-get-tabs ()
  "lists all firefox tabs"
  "list_tab_labels()")

(defun-moz-controller-command helm-firefox-tabs-js-switch-tab (name)
  "Switch to the firefox having the name"
  (concat "choose_tab_by_name(\"" name "\")"))

(setq helm-firefox-tabs-open-tabs nil)
(defun helm-firefox-tabs-load-tabs ()
  (helm-firefox-tabs-js-get-tabs)
  (setq helm-firefox-tabs-open-tabs
		(split-string moz-controller-repl-output ",")))

(defvar helm-source-firefox-tabs nil)
(setq helm-source-firefox-tabs
  '((name . "Firefox Tabs")
	(init . helm-firefox-tabs-load-tabs)
	(candidates . (lambda () helm-firefox-tabs-open-tabs))
	(action . (("Switch to Tab" . (lambda (elm) (helm-firefox-tabs-js-switch-tab elm)))))))

(defun helm-select-firefox-tab ()
  "Select a Firefox Tab in Helm"
  (interactive)
  (helm 'helm-source-firefox-tabs))
