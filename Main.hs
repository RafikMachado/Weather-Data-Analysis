-- Main.hs
-- Simple Weather Data Analysis (GHC)
-- Compile: ghc Main.hs -o weather
-- Run: ./weather

{-# LANGUAGE RecordWildCards #-}

module Main where

import System.IO
import Data.List
import Data.Ord (comparing)
import Text.Read (readMaybe)
import Control.Monad (when)

data Weather = Weather {
    date :: String,
    tempMax :: Double,
    tempMin :: Double,
    precipitation :: Double,
    humidity :: Double,
    wind :: Double
} deriving (Show, Eq)

-- parse CSV line: date,tempMax,tempMin,precipitation,humidity,wind
parseLine :: String -> Maybe Weather
parseLine line = case splitByComma line of
    [d, tmx, tmn, prec, hum, w] ->
        case (readMaybe tmx, readMaybe tmn, readMaybe prec, readMaybe hum, readMaybe w) of
            (Just tmx', Just tmn', Just prec', Just hum', Just w') ->
                Just $ Weather d tmx' tmn' prec' hum' w'
            _ -> Nothing
    _ -> Nothing

splitByComma :: String -> [String]
splitByComma s = case break (==',') s of
    (a, ',' : rest) -> a : splitByComma rest
    (a, "") -> [a]

averageTemp :: [Weather] -> Maybe Double
averageTemp [] = Nothing
averageTemp ws = Just $ sum ((\w -> (tempMax w + tempMin w)/2) <$> ws) / fromIntegral (length ws)

maxTempDays :: [Weather] -> [Weather]
maxTempDays [] = []
maxTempDays ws = filter ((== top) . (\w -> (tempMax w + tempMin w)/2)) ws
  where top = maximum $ fmap (\w -> (tempMax w + tempMin w)/2) ws

maxPrecipitationDays :: [Weather] -> [Weather]
maxPrecipitationDays [] = []
maxPrecipitationDays ws = filter ((== top) . precipitation) ws
  where top = maximum $ fmap precipitation ws

filterByTemp :: Double -> [Weather] -> [Weather]
filterByTemp threshold = filter (\w -> (tempMax w + tempMin w)/2 > threshold)

filterByDateRange :: String -> String -> [Weather] -> [Weather]
filterByDateRange start end = filter (\w -> date w >= start && date w <= end)

loadFromFile :: FilePath -> IO [Weather]
loadFromFile path = do
    exists <- doesFileExist path
    if not exists then do
        putStrLn $ "File not found: " ++ path
        return []
    else do
        txt <- readFile path
        let ls = lines txt
        let parsed = map parseLine ls
        let good = [w | Just w <- parsed]
        putStrLn $ "Loaded " ++ show (length good) ++ " records."
        return good

saveResults :: FilePath -> String -> IO ()
saveResults path content = writeFile path content >> putStrLn ("Saved to " ++ path)

doesFileExist :: FilePath -> IO Bool
doesFileExist p = do
    h <- tryIOError (openFile p ReadMode)
    case h of
        Left _ -> return False
        Right h' -> hClose h' >> return True

showWeather :: Weather -> String
showWeather Weather{..} =
    date ++ " | avg: " ++ show ((tempMax + tempMin)/2)
    ++ " | max: " ++ show tempMax ++ " | min: " ++ show tempMin
    ++ " | prec: " ++ show precipitation ++ " | hum: " ++ show humidity ++ " | wind: " ++ show wind

menu :: IO ()
menu = putStrLn $ unlines
    [ ""
    , "Weather Data Analysis"
    , "1 — Compute average temperature"
    , "2 — Find days with extreme temperature (max)"
    , "3 — Find days with maximum precipitation"
    , "4 — Filter records by temperature or date"
    , "5 — Load data from file"
    , "6 — Save results to file"
    , "0 — Exit"
    , "Select option: "
    ]

main :: IO ()
main = loop []
  where
    loop ws = do
        menu
        opt <- getLine
        case opt of
            "1" -> do
                case averageTemp ws of
                    Nothing -> putStrLn "No data loaded."
                    Just v -> putStrLn $ "Average temperature: " ++ show v
                loop ws
            "2" -> do
                let xs = maxTempDays ws
                if null xs then putStrLn "No data." else mapM_ (putStrLn . showWeather) xs
                loop ws
            "3" -> do
                let xs = maxPrecipitationDays ws
                if null xs then putStrLn "No data." else mapM_ (putStrLn . showWeather) xs
                loop ws
            "4" -> do
                putStrLn "Filter by: 1) temperature threshold  2) date range"
                c <- getLine
                case c of
                    "1" -> do
                        putStrLn "Enter temperature threshold (number):"
                        t <- getLine
                        case readMaybe t of
                            Just thr -> mapM_ (putStrLn . showWeather) (filterByTemp thr ws)
                            Nothing -> putStrLn "Invalid number."
                        loop ws
                    "2" -> do
                        putStrLn "Enter start date (YYYY-MM-DD):"
                        s <- getLine
                        putStrLn "Enter end date (YYYY-MM-DD):"
                        e <- getLine
                        mapM_ (putStrLn . showWeather) (filterByDateRange s e ws)
                        loop ws
                    _ -> putStrLn "Unknown option." >> loop ws
            "5" -> do
                putStrLn "Enter filename to load (CSV lines):"
                fname <- getLine
                newWs <- loadFromFile fname
                loop newWs
            "6" -> do
                putStrLn "Enter output filename:"
                fn <- getLine
                let content = unlines $ map showWeather ws
                saveResults fn content
                loop ws
            "0" -> putStrLn "Goodbye."
            _   -> putStrLn "Unknown option." >> loop ws
