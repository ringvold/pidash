package pidash

type Forecast struct {
	Name      string           `json:"name"`
	Id        string           `json:"id"`
	Direction SanntidDirection `json:"direction"`
}
