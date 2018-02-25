package pidash

type SanntidDirection int

// sanntidDirection defines the direction of the vehicle. It is either,
// 0 (undefined (?)), 1 or 2.
const (
	// DirAny will give you Line in any direction.
	DirAny = iota

	// DirUp will give you Line in only one direction.
	DirUp

	// DirDown will give you Line in only one direction, reverse of DirUp.
	DirDown
)

type Line struct {
	Name      string           `json:"name"`
	Id        string           `json:"id"`
	Direction SanntidDirection `json:"direction"`
}
