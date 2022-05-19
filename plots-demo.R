
# adjust the filenames here

rt <- read.csv("Rt_estimate_clinical_monitoring_20220104_cleaned_case_and_hospital_data.xlsx.csv")
reff <- read.csv("Reff_estimate_clinical_monitoring_20220104_cleaned_case_and_hospital_data.xlsx.csv")

library(ggplot2)
library(cowplot)

ggsave("rt.pdf", width=6, height=3, scale=2,
ggplot(rt, aes(x=as.Date(date))) +
  geom_ribbon(aes(ymin=Rt_estimate-standard_deviation, ymax=Rt_estimate+standard_deviation), fill='#ffcc88') +
  geom_line(aes(y=Rt_estimate), size=1) +
  ggtitle("Rt estimate") +
  xlab("Date") +
  ylab("Estimated values of Rt ± standard deviation") +
  geom_hline(yintercept=1, color='red', size=1) +
  theme_cowplot() +
  theme(panel.grid.major=element_line(color='#eeeeee'))
)

ggsave("reff.pdf", width=6, height=3, scale=2,
ggplot(reff, aes(x=as.Date(date))) +
  geom_ribbon(aes(ymin=Reff_50_lo, ymax=Reff_50_hi), fill='#ffcc88') +
  geom_line(aes(y=Reff_estimate), size=1) +
  ggtitle("Reff estimate") +
  xlab("Date") +
  ylab("Estimated values of Reff ± 50% confidence interval") +
  geom_hline(yintercept=1, color='red', size=1) +
  theme_cowplot() +
  theme(panel.grid.major=element_line(color='#eeeeee'))
)
