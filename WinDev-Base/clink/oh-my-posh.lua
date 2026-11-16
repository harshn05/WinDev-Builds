local windev = os.getenv("WINDEV_BASE")

if not windev then
    error("WINDEV_BASE is not defined")
end

local config = windev .. "\\_OhMyPosh\\_themes\\windev.omp.json"

load(io.popen(
    'oh-my-posh init cmd --config "' .. config .. '"'
):read("*a"))()