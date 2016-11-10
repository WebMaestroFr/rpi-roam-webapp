jQuery(document).ready(function ($) {
    var $connectForm = $(".roam-connect");
    var $ssidInput = $("#roam-ssid", $connectForm);
    var $passkeyInput = $("#roam-passkey", $connectForm);
    var $passkeyField = $(".roam-passkey", $connectForm);
    var $submitButton = $(".roam-submit", $connectForm);
    var $selectIcon = $(".roam-icon", $connectForm);
    var $spinner = $(".roam-spinner");
    var submitUrl = $connectForm.attr("action");
    var activeSsid = $('.roam-active', $connectForm).data('val');
    var updateForm = function () {
        if ($ssidInput.val() === activeSsid) {
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
        $.post(submitUrl, formData).done(function (ssid) {
            $passkeyInput.val('');
            if (ssid) {
                $('.roam-active', $connectForm).removeClass('roam-active');
                activeSsid = ssid;
                $('.mdl-menu__item[data-val="' + ssid + '"]', $connectForm).addClass('roam-active');
            }
            updateForm();
            $spinner.hide();
            $connectForm.show();
        });
    });
});
