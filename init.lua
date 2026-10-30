if vim.env.NVIM_APPNAME ~= "zkvim" then
  error("Start this configuration with zkvim or NVIM_APPNAME=zkvim nvim")
end

require("config.lazy")
