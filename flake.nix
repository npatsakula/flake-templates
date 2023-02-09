{
    description = "A collection of flake templates.";
    outputs = { self }: {
        templates = {
            haskell-nix = {
                path = ./haskell-nix;
                description = "haskell.nix app with library environment and test suite. X86 only.";
            };

            haskell-simple = {
              path = ./haskell-simple;
              description = "Haskell app with library environment and test suite.";
            };
        };

        defaultTemplate = self.templates.haskell-nix;
    };
}