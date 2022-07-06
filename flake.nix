{
    description = "A collection of flake templates.";
    outputs = { self }: {
        templates = {
            haskell-app = {
                path = ./haskell-app;
                description = "Haskell app with library.";
            };
        };
        defaultTemplate = self.templates.haskell-app;
    };
}