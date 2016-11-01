jQuery(document).ready(function ($) {
    var $connectForm = $(".roam-connect");
    var $ssidInput = $("#roam-ssid", $connectForm);
    var $passkeyInput = $("#roam-passkey", $connectForm);
    var $passkeyField = $(".roam-passkey", $connectForm);
    var $submitButton = $(".roam-submit", $connectForm);
    var $selectIcon = $(".roam-icon", $connectForm);
    var $spinner = $(".roam-spinner");
    var submitUrl = $connectForm.attr("action");
    var updateForm = function () {
        if ($ssidInput.val() === roamActiveSsid) {
            $selectIcon.text('check');
            $passkeyField.hide();
            $submitButton.hide();
        } else {
            $selectIcon.text('keyboard_arrow_down');
            $passkeyField.show();
            $submitButton.show();
        }
    };
    updateForm();
    $ssidInput.on('change', updateForm);
    $connectForm.submit(function (event) {
        event.preventDefault();
        var formData = $connectForm.serializeArray();
        $connectForm.hide();
        $spinner.show();
        $.post(submitUrl, formData).done(function (data) {
            $('.roam-active', $connectForm).removeClass('roam-active');
            $passkeyInput.val('');
            if (data && data.hasOwnProperty("options") && data.options.hasOwnProperty("wpa-ssid")) {
                roamActiveSsid = data.options["wpa-ssid"];
                $('.mdl-menu__item[data-val="' + roamActiveSsid + '"]', $connectForm).addClass('roam-active');
            }
            updateForm();
            $spinner.hide();
            $connectForm.show();
        });
    });
});
