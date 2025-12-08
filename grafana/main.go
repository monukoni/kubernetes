package main

import (
	"encoding/json"
	"log"

	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
	"github.com/grafana/grafana-foundation-sdk/go/units"
)

func main() {
	builder := dashboard.NewDashboardBuilder("Dashboard").
		Uid("generated-from-go").
		Refresh("1m").
		Time("now-30m", "now").
		Timezone(common.TimeZoneUtc).
		WithPanel(
			timeseries.NewPanelBuilder().
				Title("RPS").
				Unit(units.Number).
				Min(0).
				WithTarget(
					prometheus.NewDataqueryBuilder().
						Expr(`sum(rate(request_count[5m]))`).
						LegendFormat("Requests"),
				),
		).WithPanel(
		timeseries.NewPanelBuilder().
			Title("AVG RPS per pod").
			Unit(units.Number).
			Min(0).
			WithTarget(
				prometheus.NewDataqueryBuilder().
					Expr(`avg(rate(request_count[5m]))`).
					LegendFormat("Requests")),
	).WithPanel(
		timeseries.NewPanelBuilder().
			Title("RPS on each pod").
			Unit(units.Number).
			Min(0).
			WithTarget(
				prometheus.NewDataqueryBuilder().
					Expr(`rate(request_count[5m])`).
					LegendFormat("{{ pod }}")))

	dashboard, err := builder.Build()
	if err != nil {
		log.Fatalf("failed to build dashboard: %v", err)
	}

	dashboardJson, err := json.MarshalIndent(dashboard, "", "  ")
	if err != nil {
		log.Fatalf("failed to marshal dashboard: %v", err)
	}

	log.Printf("Dashboard JSON:\n%s", dashboardJson)
}
