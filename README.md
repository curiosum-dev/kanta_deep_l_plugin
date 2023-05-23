# Kanta DeepL Plugin

<div align="center">
  <br />
  <a href="https://github.com/curiosum-dev/kanta">
    <img src="./logo.png" alt="Logo" height="111">
  </a>
  <br />
  <br />
  <p style="margin-top: 3rem; font-size: 14pt;" align="center">
    DeepL Integration for <a href="https://github.com/curiosum-dev/kanta">Kanta</a>
    <br />
    <a href="https://kanta.munasoft.pl">View Demo</a>
    ·
    <a href="https://github.com/curiosum-dev/kanta_deep_l_plugin/issues">Report Bug</a>
    ·
    <a href="https://github.com/curiosum-dev/kanta_deep_l_plugin/issues">Request Feature</a>
  </p>
</div>

## About

Not all of us are polyglots, and sometimes we need the help of machine translation tools. For this reason, we have provided plug-ins for communication with external services that will allow you to translate texts into another language without knowing it. As a first step, we introduced integration with DeepL API offering 500,000 characters/month for free and more in paid plans. To use DeepL API add `Kanta.DeepL.Plugin` to the list of plugins along with the API key from your account at DeepL. New features will then be added to the Kanta UI that will allow you to translate using this tool.

## Installation

The package can be installed by adding `kanta_deep_l_plugin` to your list of dependencies in `mix.exs`:

```elixir
# mix.exs
def deps do
  [
    {:kanta, "~> 0.1.2"} # REQUIRED
    {:kanta_deep_l_plugin, "~> 0.1.0"}
  ]
end
```

```elixir
# config/config.exs
config :kanta,
  ...
  plugins: [
    {Kanta.DeepL.Plugin, api_key: "YOUR_DEEPL_API_KEY"}
  ]
```

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. We prefer gitflow and Conventional commits style but we don't require that. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE.md` for more information.

## Contact

Michał Buszkiewicz - michal@curiosum.com

Krzysztof Janiec - krzysztof.janiec@curiosum.com

Artur Ziętkiewicz - artur.zietkiewicz@curiosum.com
