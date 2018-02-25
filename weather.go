package pidash

type Symbol struct {
	Number string `json:"number"`
	Name   string `json:"name"`
	Var    string `json:"var"`
}

type Temperature struct {
	Unit  string `json:"unit"`
	Value int    `json:"value"`
}

type Time struct {
	Symbol      Symbol      `json:"symbol"`
	Temperature Temperature `json:"temperature"`
	FromTime    string      `json:"from"`
	ToTime      string      `json:"to"`
	Period      int         `json:"period"`
}

type WeatherData struct {
	Name      string `json:"name"`
	Forecasts []Time `json:"forecasts"`
	Sun       Sun    `json:"sun"`
}

type Sun struct {
	Rise string `json:"rise"`
	Set  string `json:"set"`
}
