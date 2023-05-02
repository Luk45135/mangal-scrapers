----------------------------------
-- @name    MangaFire
-- @url     https://mangafire.to
-- @author  lukasd 
-- @license MIT
----------------------------------

------------------------------------------------
---@alias manga { name: string, url: string, author: string|nil, genres: string|nil, summary: string|nil }
---@alias chapter { name: string, url: string, volume: string|nil, manga_summary: string|nil, manga_author: string|nil, manga_genres: string|nil }
---@alias page { url: string, index: number }
-------------------------------------------------

----- IMPORTS -----
Html = require("html")
Http = require("http")
Time = require("time")
Headless = require('headless')
--- END IMPORTS ---




----- VARIABLES -----
Browser = Headless.browser()
Page = Browser:page()

Client = Http.client()
Base = "https://mangafire.to"
--- END VARIABLES ---



----- MAIN -----

--- Searches for manga with given query.
-- @param query string Query to search for
-- @return manga[] Table of mangas
function SearchManga(query)
	local request = Http.request("GET", Base .. "/filter?keyword=" .. query)
    local result = Client:do_request(request)

    local doc = Html.parse(result.body)

    local mangas = {}

    local url = Base .. "/search?keyword=" .. query
    --Page:navigate(url)
    --Page:waitLoad()

    doc:find(".item"):each(function (i, s)
        local manga = { 
			name = s:find(".name"):find(".color-light"):attr("title"), 
			url = Base .. s:find(".name"):find(".color-light"):attr("href") 
		}
        mangas[i+1] = manga
    end)

    --for i, v in ipairs(Page:elements(".item-spc")) do
    --    local manga = { url = Base .. v:element(".manga-poster"):attribute("[href]"), name = v:element(".manga-poster .manga-poster-img"):attribute("[alt]") }
    --    mangas[i + 1] = manga
    --end

    return mangas
end


--- Gets the list of all manga chapters.
-- @param mangaURL string URL of the manga
-- @return chapter[] Table of chapters
function MangaChapters(mangaURL)
	--local request = Http.request("GET", mangaURL)
    --local result = Client:do_request(request)
    --local doc = Html.parse(result.body)

    Page:navigate(mangaURL)
    Page:waitLoad()

    local chapters = {}

    --doc:find("data-number"):each(function (i, s)
    --    local chapter = { 
    --        name = s:find("a"):attr("title"), 
    --        url = s:find("a"):attr("href") }
    --    chapters[i+1] = chapter
    --end)

    for i, v in ipairs(Page:elements(".chapter-list .item a")) do
        local chapter = { 
            index = i,
            name = v:attribute("title"), 
            url = v:attribute("href") }
        chapters[i + 1] = chapter
    end


    Reverse(chapters)

    return chapters
end


--- Gets the list of all pages of a chapter.
-- @param chapterURL string URL of the chapter
-- @return page[]
function ChapterPages(chapterURL)
	--local request = Http.request("GET", chapterURL)
    --local result = Client:do_request(request)
    --local doc = Html.parse(result.body)

    Page:navigate(chapterURL)
    Page:waitLoad()

    Time.sleep(3)

    local pages = {}

    --Page:find(".container-reader-chapter"):each(function (i, s)
    --    local page = { index = i, url = s:find(".iv-card "):attr("data-url") }
    --    pages[i+1] = page
    --end)

    for i, v in ipairs(Page:elements(".page img")) do
        local p = { 
            index = i, 
            url = v:attribute("src") }
        pages[i + 1] = p
    end

    return pages
end

--- END MAIN ---




----- HELPERS -----
function Reverse(t)
	local n = #t
	local i = 1
	while i < n do
		t[i], t[n] = t[n], t[i]
		i = i + 1
		n = n - 1
	end
end



--- END HELPERS ---

-- ex: ts=4 sw=4 et filetype=lua
