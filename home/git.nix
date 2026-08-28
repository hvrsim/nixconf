{
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";

      pull.rebase = true;
      rebase.autoStash = true;

      push = {
        autoSetupRemote = true;
        default = "simple";
      };

      core.editor = "vim";

      user = {
        name = "hvrsim";
        email = "cleanbaja@protonmail.com";
      };
    };
  };
}
