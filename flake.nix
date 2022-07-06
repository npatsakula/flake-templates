{
    description = "A collection of flake templates.";
    outputs = { self }: {
        templates = {
            haskell-app = {
                path = ./haskell-app;
                description = "Haskell app with library and test suite.";
            };
        };

        defaultTemplate = self.templates.haskell-app;
    };
}