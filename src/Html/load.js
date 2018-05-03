(function () {
        var node = document.getElementById('main');
        var flags = { rawUserData: (localStorage.rawUserData || "") };
        var app = Elm.Main.embed(node, flags);

        app.ports.storeSessionRaw.subscribe(function (rawUserData) {
                localStorage.rawUserData = rawUserData;
        });

        window.addEventListener("storage", function (event) {
                if (event.storageArea === localStorage && event.key === "rawUserData") {
                        app.ports.onUserChangeRaw.send(event.newValue);
                }
        }, false);

        app.ports.setTitle.subscribe(function (title) {
                document.title = title;
        });
})();