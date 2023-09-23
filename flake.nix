{
    description = "A collection of flake templates.";
    outputs = { self }: {
        templates = {
            haskell = {
              path = ./haskell;
              description = "Haskell app with library environment and test suite.";
            };

            rust-lib = {
              path = ./rust-lib;
              description = "Rust library with test-suite.";
            };

            rust-bin = {
              path = ./rust-bin;
              description = "Rust executable with container buid suite.";
            };
        };

        templates.default = self.templates.haskell;
    };
}